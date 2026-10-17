#!/usr/bin/env bash
# bin/tests/test_tablero.sh — el adaptador `grafo` del contrato del tablero, contra el backend falso
# (TABLERO_FAKE): sin red, sin tocar la API real, y con casos que fallan si el adaptador miente.
# Son los 24 casos de Laboratorio/bin/tests/test_tablero.sh traducidos al grafo (nodos, etapas, conexiones),
# más 2 del grafo: la DUDA de un bloqueo queda ESPERA_RESPUESTA_DE la PERSONA, y el carril es una RAMA.
# Uso: bash bin/tests/test_tablero.sh   · exit 0 si todos pasan.
set -uo pipefail
AQUI="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
A="$AQUI/adapters/grafo"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
# Un orquestador de mentira con su refs.yaml: el adaptador resuelve `ref tablero.*` desde SU ruta, así que
# se copia entero a un árbol temporal para que lea esta configuración y no la real.
mkdir -p "$T/orq/bin/adapters" && cp -r "$A" "$T/orq/bin/adapters/grafo"
cat > "$T/orq/refs.yaml" <<'YAML'
tablero:
  kind: grafo
  api: http://localhost:0/api/v1
  label: board
  secciones: { entendimiento: ENTENDIMIENTO, codigo: EN CODIGO, listo: LISTO PARA PR }
YAML
export TABLERO_FAKE="$T/fake"; mkdir -p "$TABLERO_FAKE"
OP="$T/orq/bin/adapters/grafo"
NODOS="$TABLERO_FAKE/nodos.json"; CONEXIONES="$TABLERO_FAKE/conexiones.json"
N=0; F=0
caso(){ N=$((N+1)); local nombre="$1" esperado="$2" codigo="$3"; shift 3
  local out rc; out=$("$@" 2>&1); rc=$?
  if [ "$rc" = "$codigo" ] && [[ "$out" == *"$esperado"* ]]; then echo "ok   $nombre"; else echo "FALLA $nombre: rc=$rc out=[$out]"; F=$((F+1)); fi; }
hoy=$(date +%d)

caso pendiente_bloqueo      "$hoy-"                 0 "$OP/pendiente" bloqueo "esperando a Tomás por el esquema" --persona "Tomás Carabantes"
caso pendiente_es_duda      '"tipo":"DUDA"'         0 jq -c '.[0]' "$NODOS"
caso pendiente_espera_persona 'ESPERA_RESPUESTA_DE' 0 bash -c "jq -c '.[0]' '$CONEXIONES' && jq -r '.[] | select(.tipo == \"PERSONA\") | .titulo' '$NODOS'"
caso pendiente_literal      "· queera, sinonigmia"  0 "$OP/pendiente" informe "queera, sinonigmia"
caso pendiente_tipo_malo    "tipo desconocido"      64 "$OP/pendiente" urgente "x"
caso pendiente_guardo_p1    '"prioridad":1'         0 jq -c '.[0]' "$NODOS"
caso pendiente_una_etiqueta '"etiquetas":["bloqueo"]' 0 jq -c '.[0]' "$NODOS"
caso pendiente_vence        '"vence":"2026-10-20"'  0 bash -c "'$OP/pendiente' confirmacion 'x' --vence 2026-10-20 >/dev/null && jq -c '.[-1]' '$NODOS'"
caso buscar_encuentra       "esquema"               0 "$OP/buscar" tomás esquema
caso buscar_vacio_es_0      ""                      0 "$OP/buscar" nadaquever
caso buscar_no_cruza        ""                      0 bash -c "'$OP/buscar' queera esquema | grep -c . ; true"

caso tarjeta_crea           "creada"                0 "$OP/tarjeta" 25699 "Feriados"
caso tarjeta_en_entendimiento '"etapa":"ENTENDIMIENTO"' 0 bash -c "jq -c '.[] | select(.titulo | startswith(\"[25699]\"))' '$NODOS'"
caso tarjeta_idempotente    "existía"               0 "$OP/tarjeta" 25699 "otro título"
caso tarjeta_una_sola       "1"                     0 bash -c "jq '[.[] | select(.titulo | startswith(\"[25699]\"))] | length' '$NODOS'"

caso etapa_mueve            "movida a «EN CODIGO»"  0 "$OP/etapa" 25699 codigo
caso etapa_ya_estaba        "ya estaba"             0 "$OP/etapa" 25699 codigo
caso etapa_desconocida      "etapa desconocida"     64 "$OP/etapa" 25699 volando
caso etapa_sin_tarjeta_4    "no hay tarjeta"        4 "$OP/etapa" 99999 listo
caso etapa_crea_con_titulo  "creada en «LISTO PARA PR»" 0 "$OP/etapa" "FASE 30" listo --titulo "husky"
caso etapa_fase_nodo        '"tipo":"FASE","titulo":"FASE 30"' 0 bash -c "jq -c '.[-1] | {tipo, titulo}' '$NODOS'"

printf 'especificación\nde la pieza\n' > "$T/spec.md"
caso borrador_crea          "2️⃣ 20379 · 3.1"       0 "$OP/borrador" "C · Recepción" "2️⃣ 20379 · 3.1 · Iniciar" --descripcion-archivo "$T/spec.md"
caso borrador_en_rama       '"tipo":"RAMA","titulo":"C · Recepción"' 0 bash -c "jq -c '.[] | select(.tipo == \"RAMA\") | {tipo, titulo}' '$NODOS'"
caso borrador_pertenece     'PERTENECE_A'           0 jq -c '.[-1]' "$CONEXIONES"
caso borrador_descripcion   'de la pieza'           0 jq -r '.[-1].descripcion' "$NODOS"
caso borrador_archivo_malo  "no existe"             1 "$OP/borrador" "A" "x" --descripcion-archivo "$T/nada.md"

# `tablero: none` apaga todo el adaptador: ref sale 3 y el script no llega a la API.
printf 'tablero: none\n' > "$T/orq/refs.yaml"
caso apagado_sale_3         "none"                  3 "$OP/pendiente" bloqueo "x"
echo "casos: $N · fallas: $F"; [ "$F" = 0 ]
