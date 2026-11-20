#!/usr/bin/env bash
# bin/tests/test_desplegar_env.sh — `valor_env` de deploy/desplegar-aqui.sh: lo que el deploy conserva del .env al reescribirlo.
# Caso real (2026-11-16): una clave repetida, vacía y con valor, hizo que dos deploys seguidos borraran la URL de Kuma.
# Uso: bash bin/tests/test_desplegar_env.sh · `DESPLEGAR` apunta a otra copia del script (para probar que el test la detecta).
set -uo pipefail
AQUI="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
DESPLEGAR="${DESPLEGAR:-$AQUI/../deploy/desplegar-aqui.sh}"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
export GRAFO_SOLO_FUNCIONES=1
# shellcheck source=/dev/null
source "$DESPLEGAR"

casos=0; fallas=0
espera() { # $1 nombre · $2 esperado · $3 obtenido
  casos=$((casos + 1))
  if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FALLA $1: esperaba «$2», dio «$3»"; fallas=$((fallas + 1)); fi
}
URL=http://host.docker.internal:3005/api/push/abc

printf 'POSTGRES_PASSWORD=clave\nKUMA_PUSH_URL_RESPALDO=%s\n' "$URL" > "$T/simple"
espera "una línea con valor" "$URL" "$(valor_env "$T/simple" KUMA_PUSH_URL_RESPALDO)"

printf 'KUMA_PUSH_URL_RESPALDO=\nKUMA_PUSH_URL_RESPALDO=%s\n' "$URL" > "$T/repetida"
espera "vacía y después con valor (el caso del Mac)" "$URL" "$(valor_env "$T/repetida" KUMA_PUSH_URL_RESPALDO)"

printf 'KUMA_PUSH_URL_RESPALDO=%s\nKUMA_PUSH_URL_RESPALDO=\n' "$URL" > "$T/al_reves"
espera "con valor y después vacía" "$URL" "$(valor_env "$T/al_reves" KUMA_PUSH_URL_RESPALDO)"

printf 'POSTGRES_PASSWORD=\nPOSTGRES_PASSWORD=clave\n' > "$T/clave"
espera "contraseña repetida no se corrompe" "clave" "$(valor_env "$T/clave" POSTGRES_PASSWORD)"

printf 'POSTGRES_PASSWORD=clave\n' > "$T/sin_kuma"
espera "clave ausente da vacío" "" "$(valor_env "$T/sin_kuma" KUMA_PUSH_URL_RESPALDO)"
espera "archivo inexistente da vacío" "" "$(valor_env "$T/no_existe" POSTGRES_PASSWORD)"

echo "casos: $casos · fallas: $fallas"
[ "$fallas" -eq 0 ]
