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
proyecto: prueba
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

caso pendiente_bloqueo      "$hoy-"                 0 "$OP/pendiente" bloqueo "esperando a Persona A por el esquema" --persona "Persona A"
caso pendiente_es_duda      '"tipo":"DUDA"'         0 jq -c '.[0]' "$NODOS"
caso pendiente_espera_persona 'ESPERA_RESPUESTA_DE' 0 bash -c "jq -c '.[0]' '$CONEXIONES' && jq -r '.[] | select(.tipo == \"PERSONA\") | .titulo' '$NODOS'"
caso pendiente_literal      "· queera, sinonigmia"  0 "$OP/pendiente" informe "queera, sinonigmia"
caso pendiente_tipo_malo    "tipo desconocido"      64 "$OP/pendiente" urgente "x"
caso pendiente_fecha_una_vez "igual"                0 bash -c "'$OP/pendiente' informe '18-oct · ya traía la fecha' >/dev/null &&
  [ \"\$(jq -r '.[-1].titulo' '$NODOS')\" = '18-oct · ya traía la fecha' ] && echo igual"
caso pendiente_guardo_p1    '"prioridad":1'         0 jq -c '.[0]' "$NODOS"
caso pendiente_una_etiqueta '"etiquetas":["bloqueo"]' 0 jq -c '.[0]' "$NODOS"
caso pendiente_vence        '"vence":"2026-10-20"'  0 bash -c "'$OP/pendiente' confirmacion 'x' --vence 2026-10-20 >/dev/null && jq -c '.[-1]' '$NODOS'"
# Lo que se dice en la daily es «para decir», no una tarea (Freddy, 2026-10-18): DAILY_ITEM EN_DAILY_DE el ritual de la API.
caso pendiente_para_decir   '{"tipo":"DAILY_ITEM","etiquetas":["complemento:para-decir"]}' 0 \
  jq -c '[.[] | select(.titulo | endswith("queera, sinonigmia"))][0] | {tipo, etiquetas}' "$NODOS"
caso pendiente_en_la_daily  "EN_DAILY_DE Daily"     0 bash -c "jq -r --slurpfile n '$NODOS' '
  (\$n[0][] | select(.titulo | endswith(\"queera, sinonigmia\")) | .id) as \$item
  | (\$n[0][] | select(.externoOrigen == \"ritual\" and .externoId == \"daily\")) as \$ritual
  | .[] | select(.origenId == \$item and .destinoId == \$ritual.id) | \"\(.tipo) \(\$ritual.titulo)\"' '$CONEXIONES'"
caso pendiente_un_ritual    "1"                     0 jq -r '[.[] | select(.externoOrigen == "ritual")] | length' "$NODOS"
caso pendiente_sin_ritual   "no declara el ritual «daily»" 1 bash -c "mkdir -p '$T/sin-daily' &&
  echo '{\"rituales\":[{\"clave\":\"retro\",\"nombre\":\"Retro\"}]}' > '$T/sin-daily/area.json' &&
  TABLERO_FAKE='$T/sin-daily' '$OP/pendiente' informe x"
caso pendiente_sin_ritual_no_escribe "true"         0 jq -r 'length == 0' "$T/sin-daily/nodos.json"
caso buscar_encuentra       "esquema"               0 "$OP/buscar" persona esquema
caso buscar_vacio_es_0      ""                      0 "$OP/buscar" nadaquever
caso buscar_no_cruza        ""                      0 bash -c "'$OP/buscar' queera esquema | grep -c . ; true"

caso tarjeta_crea           "creada"                0 "$OP/tarjeta" 25699 "Feriados"
caso tarjeta_en_entendimiento '"etapa":"ENTENDIMIENTO"' 0 bash -c "jq -c '.[] | select(.titulo | startswith(\"[25699]\"))' '$NODOS'"
caso tarjeta_idempotente    "existía"               0 "$OP/tarjeta" 25699 "otro título"
caso tarjeta_una_sola       "1"                     0 bash -c "jq '[.[] | select(.titulo | startswith(\"[25699]\"))] | length' '$NODOS'"
# C12: la pieza del plan que ya lleva el id de su task es la misma tarjeta: al tomarla pasa a trabajo, no se crea otra.
jq '. + [{id:"pz1", tipo:"TAREA", titulo:"5️⃣ 🟢 [26310] Avisos · por la cola", estado:"ABIERTO", cara:"PLAN", etapa:null, etiquetas:["pieza","ronda:5"]}]' "$NODOS" > "$NODOS.tmp" && mv "$NODOS.tmp" "$NODOS"
caso tarjeta_toma_la_pieza  "tomada"                0 "$OP/tarjeta" 26310 "Avisos"
caso tarjeta_pieza_a_trabajo '{"cara":"REAL","etapa":"ENTENDIMIENTO","titulo":"[26310] Avisos"}' 0 jq -c '.[] | select(.id == "pz1") | {cara, etapa, titulo}' "$NODOS"
caso tarjeta_pieza_sin_otra '1'                     0 bash -c "jq '[.[] | select(.titulo | contains(\"[26310]\"))] | length' '$NODOS'"
caso tarjeta_pieza_tomada_existe "existía"          0 "$OP/tarjeta" 26310 "Avisos"

caso etapa_mueve            "movida a «EN CODIGO»"  0 "$OP/etapa" 25699 codigo
caso etapa_ya_estaba        "ya estaba"             0 "$OP/etapa" 25699 codigo
caso etapa_desconocida      "etapa desconocida"     64 "$OP/etapa" 25699 volando
caso etapa_sin_tarjeta_4    "no hay tarjeta"        4 "$OP/etapa" 99999 listo
caso etapa_crea_con_titulo  "creada en «LISTO PARA PR»" 0 "$OP/etapa" "FASE 30" listo --titulo "husky"
caso etapa_fase_nodo        '"tipo":"FASE","titulo":"FASE 30"' 0 bash -c "jq -c '.[-1] | {tipo, titulo}' '$NODOS'"
caso etapa_fase_externo    '"externoOrigen":"fases-md:prueba","externoId":"fase:30"' 0 bash -c "jq -c '.[-1] | {externoOrigen, externoId}' '$NODOS'"
# La «FASE 31» que dejó el importador (cerrada) y otra «FASE 31» de Todoist: se mueve la del importador, no se crea otra.
jq '. + [{id:"imp31", tipo:"FASE", titulo:"FASE 31", estado:"CERRADO", etapa:"CERRADO", etiquetas:[], externoOrigen:"fases-md:prueba", externoId:"fase:31"},
         {id:"tod31", tipo:"FASE", titulo:"FASE 31", estado:"ABIERTO", etapa:null, etiquetas:[], externoOrigen:"todoist", externoId:"fase:31"}]' "$NODOS" > "$NODOS.tmp" && mv "$NODOS.tmp" "$NODOS"
caso etapa_fase_del_importador "imp31"               0 "$OP/etapa" "FASE 31" listo
caso etapa_fase_otra_intacta   'null'                0 jq -r '.[] | select(.id == "tod31") | .etapa' "$NODOS"
caso etapa_fase_sin_duplicar   "2"                   0 bash -c "jq '[.[] | select(.titulo == \"FASE 31\")] | length' '$NODOS'"

printf 'especificación\nde la pieza\n' > "$T/spec.md"
caso borrador_crea          "2️⃣ 20379 · 3.1"       0 "$OP/borrador" "C · Recepción" "2️⃣ 20379 · 3.1 · Iniciar" --descripcion-archivo "$T/spec.md"
# La regla de la pieza (cara PLAN, ronda, HU y carril) la aplica la API en POST /piezas, la misma del importador: el
# adaptador le pasa el carril, el título y la especificación, y no la repite (el backend falso solo guarda lo pedido).
caso borrador_pide_pieza    '{"cara":"PLAN","carril":"C · Recepción"}' 0 jq -c '.[-1] | {cara, carril}' "$NODOS"
caso borrador_descripcion   'de la pieza'           0 jq -r '.[-1].descripcion' "$NODOS"
caso borrador_sin_spec      "falta --descripcion-archivo" 64 "$OP/borrador" "C · Recepción" "x"
caso borrador_archivo_malo  "no existe"             1 "$OP/borrador" "A" "x" --descripcion-archivo "$T/nada.md"
# La tarjeta de una task que ya existe, como la deja /flow:pbi:repartir en modo acomodar: con `[<task>]` en el título,
# tomarla la pasa a trabajo. Con la task al final y sin corchetes (`· 25312`) se creaba otra (2026-10-26).
printf '# 1.1 · Bandeja  HU 20379 · task 25312\n' > "$T/task.md"
"$OP/borrador" "B · Bandeja" "1️⃣ 20379 · 1.1 · Bandeja · [25312]" --descripcion-archivo "$T/task.md" > /dev/null
caso borrador_task_se_toma  "tomada"                0 "$OP/tarjeta" 25312 "Bandeja"
caso borrador_task_una_sola "1"                     0 bash -c "jq '[.[] | select(.titulo | contains(\"25312\"))] | length' '$NODOS'"
# El orden del reparto viaja con la pieza: `--depende-de <id>` deja la nueva DEPENDE_DE la anterior (2026-10-26: las flechas se
# agregaron a mano después de pasar las tarjetas).
PRIMERA=$("$OP/borrador" "B · Bandeja" "1️⃣ 20379 · 1.1 · Primera" --descripcion-archivo "$T/spec.md" | cut -f1)
caso borrador_depende_crea  "Segunda"               0 "$OP/borrador" "B · Bandeja" "2️⃣ 20379 · 1.2 · Segunda" --descripcion-archivo "$T/spec.md" --depende-de "$PRIMERA"
caso borrador_depende_flecha "DEPENDE_DE"            0 bash -c "jq -r --slurpfile n '$NODOS' '(\$n[0][] | select(.titulo | contains(\"1.2 · Segunda\")) | .id) as \$s | .[] | select(.origenId == \$s and .destinoId == \"$PRIMERA\") | .tipo' '$CONEXIONES'"
caso borrador_depende_vacio "falta el id"           64 "$OP/borrador" "B · Bandeja" "x" --descripcion-archivo "$T/spec.md" --depende-de

# Sin conexión con la API (el Mac Mini apagado), contra la API de verdad y no la falsa: curl escribe el código 000, y
# eso no puede pasar por éxito. Real 2026-10-18, ensayo del corte: pendiente y tarjeta salían 0 sin haber guardado nada.
sed -i 's#^  api: .*#  api: http://127.0.0.1:9/api/v1#' "$T/orq/refs.yaml"
caso api_caida_pendiente    "sin conexión"          1 env -u TABLERO_FAKE "$OP/pendiente" informe "x"
caso api_caida_tarjeta      "sin conexión"          1 env -u TABLERO_FAKE "$OP/tarjeta" 99903 "x"

# `tablero: none` apaga todo el adaptador: ref sale 3 y el script no llega a la API.
printf 'tablero: none\n' > "$T/orq/refs.yaml"
caso apagado_sale_3         "none"                  3 "$OP/pendiente" bloqueo "x"
echo "casos: $N · fallas: $F"; [ "$F" = 0 ]
