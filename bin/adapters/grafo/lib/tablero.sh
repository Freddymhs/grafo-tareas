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
#   tarjeta    → TAREA `[<id>] <título>` en la primera etapa · etapa → PATCH etapa del nodo (`[<id>]` = TAREA
#                por prefijo; `FASE n` = nodo FASE con ese título exacto, como los deja el importador)
#   borrador   → TAREA en una RAMA llamada como el carril (PERTENECE_A), etiqueta `borrador`
#
# Salida de toda operación: `<id>\t<titulo>` por línea. Error → exit ≠ 0 con el motivo por stderr.
# TABLERO_FAKE=<dir> reemplaza la API por archivos JSON (nodos.json, conexiones.json): los tests corren sin red.
set -euo pipefail

ORQ="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../../../.." && pwd)"
readonly ORQ
readonly ETIQUETA_BORRADOR=borrador
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
    if [ "$codigo" -ge 400 ] 2>/dev/null || [ -z "$codigo" ]; then
      echo "API $1 $2 → $codigo: $(printf '%s' "$cuerpo" | jq -r '.message // .' 2>/dev/null || printf '%s' "$cuerpo")" >&2
      exit 1
    fi
    printf '%s\n' "$cuerpo" | jq -c '.data'
  }
  gr_listar() {
    local q estado; q=$(jq -rn --arg q "$1" '$q | @uri'); estado="${3:-ABIERTO}"
    [ "$estado" = TODOS ] && estado=""
    _gr_curl GET "/nodos?limit=$LIMITE_LISTA&q=$q${2:+&tipo=$2}${estado:+&estado=$estado}" | jq -c '.data'
  }
  gr_crear()    { _gr_curl POST "/nodos" "$1"; }
  gr_editar()   { _gr_curl PATCH "/nodos/$1" "$2"; }
  gr_conectar() { _gr_curl POST "/conexiones" "$(jq -nc --arg o "$1" --arg d "$2" --arg t "$3" '{origenId: $o, destinoId: $d, tipo: $t}')"; }
fi

# El nodo abierto cuyo título empieza con `<prefijo>` (`[25699]`): objeto JSON, o nada.
nodo_por_prefijo() {   # $1 prefijo · $2 tipo (opcional)
  gr_listar "$1" "${2:-}" | jq -c --arg p "$1" '[.[] | select(.titulo | startswith($p))] | first // empty'
}

# El externo con el que `importar:fases` (grafo-tareas.api) escribe las FASE: `fases-md:<proyecto>` / `fase:<n>`.
# Es el mismo valor que `origenFases()` de la API (src/importadores/fases/traducir-fases.ts): si cambia allá, cambia acá.
readonly ORIGEN_FASES_PREFIJO=fases-md

# La FASE n de ESTE orquestador, abierta o cerrada: el mismo nodo que escribe el importador. Así el hook (por
# `etapa`) y `importar:fases` marcan un solo nodo, y una «FASE n» de otro proyecto o de Todoist no se toca (C10).
nodo_fase() {   # $1 número
  local proyecto
  proyecto=$(REF_DESDE="$ORQ" ref proyecto) || { echo "falta \`proyecto\` en refs.yaml: sin él no sé de qué orquestador es la FASE" >&2; return 1; }
  gr_listar "FASE $1" FASE TODOS |
    jq -c --arg o "$ORIGEN_FASES_PREFIJO:$proyecto" --arg i "fase:$1" '[.[] | select(.externoOrigen == $o and .externoId == $i)] | first // empty'
}

externo_fase() {   # $1 número → {externoOrigen, externoId} para crearla igual que el importador
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
