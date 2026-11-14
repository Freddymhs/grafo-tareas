# lib/tablero.sh — compartido por bin/adapters/grafo/*: el adaptador `grafo` del CONTRATO DEL TABLERO.
#
#   source "$(dirname "$(readlink -f "$0")")/lib/tablero.sh"
#
# Mismo contrato que Laboratorio/bin/adapters/todoist (PORTAR.md §El contrato del tablero), contra la API
# REST de grafo-tareas.api (Swagger en /docs). Configuración por `ref tablero.*`: `api` (base, con /api/v1),
# `token_env` (opcional: nombre de la variable con el bearer), `label`, `secciones: { etapa: nombre }`.
# Las secciones son las etapas de la API (`GET /etapas`): un nombre que la API no conoce da 400.
#
# Cómo se traduce cada tarjeta al grafo:
#   pendiente  → nodo TAREA (DUDA si es `bloqueo`) con prioridad, UNA etiqueta y `vence`; con --persona,
#                DUDA --ESPERA_RESPUESTA_DE--> PERSONA (se crea si falta)
#   tarjeta    → TAREA `[<id>] <título>` en la primera etapa; si el plan ya tiene la pieza con ese id, ésa pasa a
#                trabajo (C12: una tarjeta, no dos) · etapa → PATCH etapa del nodo (`[<id>]` = TAREA por prefijo;
#                `FASE n` = el nodo FASE del importador)
#   borrador   → `POST /piezas`: la API le aplica la regla de la pieza (cara PLAN, ronda, su HU y la RAMA del carril)
#
# Salida de toda operación: `<id>\t<titulo>` por línea. Error → exit ≠ 0 con el motivo por stderr.
# TABLERO_FAKE=<dir> reemplaza la API por archivos JSON (nodos.json, conexiones.json): los tests corren sin red.
set -euo pipefail

ORQ="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../../.." && pwd)"
readonly ORQ
readonly LIMITE_LISTA=500

# exit 1 falta la clave · 3 `tablero: none` (apagado a propósito: se dice por stderr y se sale con el mismo 3)
cfg() {
  local valor rc
  valor=$(REF_DESDE="$ORQ" ref "tablero.$1") || { rc=$?; [ "$rc" = 3 ] && echo "tablero: none en refs.yaml — el tablero está apagado" >&2; exit "$rc"; }
  printf '%s\n' "$valor"
}
cfg_opcional() { REF_DESDE="$ORQ" ref "tablero.$1" 2>/dev/null || true; }

# El método habla en p1..p4; la API también (1 = la más urgente).
prioridad_api() {
  case "$1" in p1) echo 1 ;; p2) echo 2 ;; p3) echo 3 ;; p4) echo 4 ;; *) echo "prioridad desconocida: $1" >&2; return 1 ;; esac
}

fecha_hoy() {   # "<DD-mmm>" en español: es el prefijo que impone /flow:todo §2
  local meses=(ene feb mar abr may jun jul ago sep oct nov dic)
  printf '%s-%s' "$(date +%d)" "${meses[$((10#$(date +%m) - 1))]}"
}

linea() { jq -r '[.id, .titulo] | @tsv'; }   # el formato de salida, uno por nodo

# Se lee SIEMPRE, también con TABLERO_FAKE: `tablero: none` apaga el adaptador (exit 3) antes de tocar nada,
# y un `kind` distinto es un refs.yaml que apunta a otro adaptador.
KIND=$(cfg kind)
[ "$KIND" = grafo ] || { echo "tablero.kind es «$KIND», este adaptador es grafo" >&2; exit 1; }

if [ -n "${TABLERO_FAKE:-}" ]; then
  # ── backend falso: mismas operaciones que la API, estado en archivos ──────────────────────────
  FAKE_NODOS="$TABLERO_FAKE/nodos.json"; FAKE_CONEXIONES="$TABLERO_FAKE/conexiones.json"
  [ -f "$FAKE_NODOS" ] || echo '[]' > "$FAKE_NODOS"
  [ -f "$FAKE_CONEXIONES" ] || echo '[]' > "$FAKE_CONEXIONES"
  _fake_append() {   # $1 archivo · $2 prefijo del id · $3 objeto sin id → lo guarda y lo imprime
    local nuevo
    nuevo=$(jq -c --arg p "$2" --argjson o "$3" '($o + {id: ($p + (length + 1 | tostring))})' "$1")
    jq --argjson n "$nuevo" '. + [$n]' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
    printf '%s\n' "$nuevo"
  }
  gr_listar() {   # $1 texto (contenido en el título, sin mayúsculas) · $2 tipo · $3 estado (ABIERTO; TODOS = cualquiera) → array
    jq -c --arg q "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" --arg t "${2:-}" --arg e "${3:-ABIERTO}" \
      '[.[] | select(($e == "TODOS" or .estado == $e) and ($t == "" or .tipo == $t) and ((.titulo | ascii_downcase) | contains($q)))]' "$FAKE_NODOS"
  }
  gr_crear() { _fake_append "$FAKE_NODOS" n "$(jq -c '{estado: "ABIERTO", etiquetas: [], etapa: null} + .' <<<"$1")"; }
  gr_editar() {   # $1 id · $2 cambios JSON → el nodo editado
    jq --arg id "$1" --argjson c "$2" 'map(if .id == $id then . + $c else . end)' "$FAKE_NODOS" > "$FAKE_NODOS.tmp" && mv "$FAKE_NODOS.tmp" "$FAKE_NODOS"
    jq -c --arg id "$1" '.[] | select(.id == $id)' "$FAKE_NODOS"
  }
  gr_conectar() { _fake_append "$FAKE_CONEXIONES" c "$(jq -nc --arg o "$1" --arg d "$2" --arg t "$3" '{origenId: $o, destinoId: $d, tipo: $t}')"; }
  # Guarda lo pedido sin aplicar la regla de la pieza: ésa vive en la API y la prueban sus e2e (piezas.e2e-spec.ts).
  gr_pieza() { gr_crear "$(jq -c '{tipo: "TAREA", cara: "PLAN", titulo, descripcion, carril}' <<<"$1")"; }
  # El área de `GET /area`: area.json si el test la escribe; si no, la que tiene la daily (la de todos los días).
  gr_area() {
    if [ -f "$TABLERO_FAKE/area.json" ]; then jq -c . "$TABLERO_FAKE/area.json"
    else echo '{"rituales":[{"clave":"daily","nombre":"Daily"}]}'; fi
  }
else
  # ── la API real ────────────────────────────────────────────────────────────────────────────────
  API=$(cfg api)
  TOKEN_ENV=$(cfg_opcional token_env)
  TOKEN="${TOKEN_ENV:+${!TOKEN_ENV:-}}"
  _gr_curl() {   # $1 método · $2 ruta · $3 cuerpo JSON (opcional) → `.data` de la respuesta; error → stderr, exit 1
    local respuesta codigo cuerpo
    respuesta=$(curl -sS -w '\n%{http_code}' -X "$1" "$API$2" -H 'Content-Type: application/json' \
      ${TOKEN:+-H "Authorization: Bearer $TOKEN"} ${3:+--data "$3"})
    codigo=${respuesta##*$'\n'}; cuerpo=${respuesta%$'\n'*}
    # Sin conexión curl igual escribe un código: 000. Solo un 2xx es éxito (con «≥ 400» el 000 pasaba y no se guardaba nada).
    case "$codigo" in
      2??) ;;
      000 | '')
        echo "API $1 $2 → sin conexión con $API" >&2
        exit 1 ;;
      *)
        echo "API $1 $2 → $codigo: $(printf '%s' "$cuerpo" | jq -r '.message // .' 2>/dev/null || printf '%s' "$cuerpo")" >&2
        exit 1 ;;
    esac
    printf '%s\n' "$cuerpo" | jq -c '.data'
  }
  gr_listar() {
    local q estado; q=$(jq -rn --arg q "$1" '$q | @uri'); estado="${3:-ABIERTO}"
    [ "$estado" = TODOS ] && estado=""
    # Un `q=` vacío da 400 (Validation failed): sin texto, no se manda.
    _gr_curl GET "/nodos?limit=$LIMITE_LISTA${q:+&q=$q}${2:+&tipo=$2}${estado:+&estado=$estado}" | jq -c '.data'
  }
  gr_crear()    { _gr_curl POST "/nodos" "$1"; }
  gr_editar()   { _gr_curl PATCH "/nodos/$1" "$2"; }
  gr_conectar() { _gr_curl POST "/conexiones" "$(jq -nc --arg o "$1" --arg d "$2" --arg t "$3" '{origenId: $o, destinoId: $d, tipo: $t}')"; }
  gr_pieza()    { _gr_curl POST "/piezas" "$1"; }
  gr_area()     { _gr_curl GET "/area"; }
fi

# El nodo abierto cuyo título empieza con `<prefijo>` (`[25699]`): objeto JSON, o nada.
nodo_por_prefijo() {   # $1 prefijo · $2 tipo (opcional)
  gr_listar "$1" "${2:-}" | jq -c --arg p "$1" '[.[] | select(.titulo | startswith($p))] | first // empty'
}

# El externo de las FASE en el grafo: `fases-md:<proyecto>` / `fase:<n>`. Lo dejó el viejo `importar:fases` (salió en la
# FASE 25) y lo sigue usando este adaptador al crear la tarjeta: las FASE que ya están lo llevan, no se cambia.
readonly ORIGEN_FASES_PREFIJO=fases-md

# La FASE n de ESTE orquestador, abierta o cerrada, por su externo: el hook (por `etapa`) y el adaptador marcan un solo
# nodo, y una «FASE n» de otro proyecto o de otro origen no se toca (C10).
nodo_fase() {   # $1 número
  local proyecto
  proyecto=$(REF_DESDE="$ORQ" ref proyecto) || { echo "falta \`proyecto\` en refs.yaml: sin él no sé de qué orquestador es la FASE" >&2; return 1; }
  gr_listar "FASE $1" FASE TODOS |
    jq -c --arg o "$ORIGEN_FASES_PREFIJO:$proyecto" --arg i "fase:$1" '[.[] | select(.externoOrigen == $o and .externoId == $i)] | first // empty'
}

externo_fase() {   # $1 número → {externoOrigen, externoId} para crearla con el externo de las FASE
  jq -nc --arg o "$ORIGEN_FASES_PREFIJO:$(REF_DESDE="$ORQ" ref proyecto)" --arg i "fase:$1" '{externoOrigen: $o, externoId: $i}'
}

# El nodo abierto con ese título exacto y tipo: objeto JSON, o nada.
nodo_por_titulo() {   # $1 título · $2 tipo
  gr_listar "$1" "$2" | jq -c --arg t "$1" '[.[] | select(.titulo == $t)] | first // empty'
}

# Id del nodo `<tipo>` titulado `<título>`; si no existe lo crea (PERSONA para los bloqueos, RAMA para los carriles).
nodo_id_o_crear() {   # $1 tipo · $2 título
  local existente id
  existente=$(nodo_por_titulo "$2" "$1")
  if [ -n "$existente" ]; then printf '%s' "$existente" | jq -r .id; return; fi
  id=$(gr_crear "$(jq -nc --arg t "$1" --arg ti "$2" '{tipo: $t, titulo: $ti}')" | jq -r .id)
  [ -n "$id" ] && [ "$id" != null ] || { echo "no pude crear el nodo $1 «$2»" >&2; return 1; }
  printf '%s\n' "$id"
}

# El externo con que la API escribe el nodo de un ritual (`ORIGEN_RITUAL`, grafo-tareas.api complementos.repository.ts):
# si cambia allá, cambia acá. Así lo «para decir» de este adaptador y lo de `POST /nodos/:id/complementos` cuelgan del mismo.
readonly ORIGEN_RITUAL=ritual

# Id del nodo del ritual `<clave>` de GET /area (la daily, la retro: los del área, no del método); si falta, lo crea
# como la API. Sin ese ritual en el área sale 1 antes de que el que llama escriba nada.
nodo_de_ritual() {   # $1 clave
  local nombre existente id
  nombre=$(gr_area | jq -r --arg c "$1" '.rituales[] | select(.clave == $c) | .nombre') || return 1
  [ -n "$nombre" ] || { echo "el área no declara el ritual «$1» (\`rituales:\` del refs.yaml que lee la API, GET /area)" >&2; return 1; }
  existente=$(gr_listar "" DAILY_ITEM TODOS |
    jq -r --arg o "$ORIGEN_RITUAL" --arg c "$1" '[.[] | select(.externoOrigen == $o and .externoId == $c)] | first | .id // empty')
  if [ -n "$existente" ]; then printf '%s\n' "$existente"; return; fi
  id=$(gr_crear "$(jq -nc --arg ti "$nombre" --arg o "$ORIGEN_RITUAL" --arg c "$1" \
    '{tipo: "DAILY_ITEM", titulo: $ti, externoOrigen: $o, externoId: $c}')" | jq -r .id)
  [ -n "$id" ] && [ "$id" != null ] || { echo "no pude crear el nodo del ritual «$1»" >&2; return 1; }
  printf '%s\n' "$id"
}
