#!/usr/bin/env bash
# bin/tests/test_desplegar_traer.sh — `traer` de deploy/desplegar-aqui.sh (qué commit de cada repo avanza), sin red ni Docker:
# un bare como origin y dos commits en un directorio temporal. Casos: SHA actual avanza, SHA viejo no avanza y sale 0,
# SHA fuera de main falla, primer clon con SHA queda en él, sin SHA va a origin/main. Uso: bash bin/tests/test_desplegar_traer.sh
# `DESPLEGAR` apunta a otra copia del script (así se prueba que el test detecta un arreglo revertido).
set -uo pipefail
AQUI="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
DESPLEGAR="${DESPLEGAR:-$AQUI/../deploy/desplegar-aqui.sh}"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export HOME="$T/home" GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null   # ni el ~/.gitconfig ni el $HOME real
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
export GRAFO_GITHUB="$T/origen" GRAFO_SOLO_FUNCIONES=1
mkdir -p "$HOME" "$GRAFO_GITHUB"
REPO=grafo-tareas.api

# Origen: un bare con main = c1 → c2, y una rama `otra` con un commit que main no tiene.
git init -q --bare -b main "$GRAFO_GITHUB/$REPO.git"
git init -q -b main "$T/trabajo"
git -C "$T/trabajo" remote add origin "$GRAFO_GITHUB/$REPO.git"
git -C "$T/trabajo" commit -q --allow-empty -m c1; C1=$(git -C "$T/trabajo" rev-parse HEAD)
git -C "$T/trabajo" commit -q --allow-empty -m c2; C2=$(git -C "$T/trabajo" rev-parse HEAD)
git -C "$T/trabajo" push -q origin main
git -C "$T/trabajo" checkout -q -b otra "$C1"
git -C "$T/trabajo" commit -q --allow-empty -m rara; RARO=$(git -C "$T/trabajo" rev-parse HEAD)
git -C "$T/trabajo" push -q origin otra

# Un clon que va atrás (en c1), como el Mac Mini antes del despliegue.
clon_en_c1() { rm -rf "$1"; git clone -q --branch main "$GRAFO_GITHUB/$REPO.git" "$1"; git -C "$1" reset -q --hard "$C1"; }

N=0; F=0
# caso <nombre> <rc esperado> <fragmento esperado en la salida> <HEAD esperado del clon o -> <dir> [<sha>]
caso() { N=$((N+1)); local nombre="$1" rc_esperado="$2" texto="$3" head_esperado="$4" dir="$5" sha="${6:-}" out rc head
  out=$( ( source "$DESPLEGAR"; traer "$dir" "$REPO" ${sha:+"$sha"}; echo "TERMINO-TRAER" ) 2>&1 ); rc=$?
  head=$(git -C "$dir" rev-parse HEAD 2>/dev/null || echo nada)
  if [ "$rc" = "$rc_esperado" ] && [[ "$out" == *"$texto"* ]] && { [ "$head_esperado" = - ] || [ "$head" = "$head_esperado" ]; }; then
    echo "ok   $nombre"
  else echo "FALLA $nombre: rc=$rc (esperaba $rc_esperado) head=$head (esperaba $head_esperado) out=[$out]"; F=$((F+1)); fi; }

clon_en_c1 "$T/a"
caso sha_actual_avanza          0 "TERMINO-TRAER"          "$C2" "$T/a" "$C2"

clon_en_c1 "$T/b"
caso sha_viejo_no_avanza_exit0  0 "hay un commit más nuevo" "$C1" "$T/b" "$C1"
out=$( ( source "$DESPLEGAR"; traer "$T/b" "$REPO" "$C1"; echo "TERMINO-TRAER" ) 2>&1 )
N=$((N+1)); if [[ "$out" == *TERMINO-TRAER* ]]; then echo "FALLA sha_viejo_corta_el_script: siguió corriendo"; F=$((F+1)); else echo "ok   sha_viejo_corta_el_script"; fi

clon_en_c1 "$T/c"
caso sha_fuera_de_main_falla    1 "no está en origin/main" "$C1" "$T/c" "$RARO"
caso sha_inexistente_falla      1 "no existe"              "$C1" "$T/c" "0123456789012345678901234567890123456789"

clon_en_c1 "$T/d"
caso sin_sha_va_a_origin_main   0 "TERMINO-TRAER"          "$C2" "$T/d"

caso primer_clon_con_sha        0 "TERMINO-TRAER"          "$C2" "$T/nuevo1" "$C2"
caso primer_clon_sha_viejo_sale0 0 "No avanzo"             "$C2" "$T/nuevo2" "$C1"
caso primer_clon_sha_raro_falla 1 "no está en origin/main" "$C2" "$T/nuevo3" "$RARO"
caso primer_clon_sin_sha        0 "TERMINO-TRAER"          "$C2" "$T/nuevo4"

echo "casos: $N · fallas: $F"
[ "$F" = 0 ] && [ "$N" -gt 0 ]
