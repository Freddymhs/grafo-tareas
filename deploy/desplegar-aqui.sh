#!/usr/bin/env bash
# desplegar-aqui.sh — FASE 27: corre EN el Mac Mini y deja en producción el `main` publicado de grafo-tareas
# (orquestador, api, web y vr) con deploy/compose.yml. Lo llaman dos caminos, con el mismo código:
#   · el job `deploy` del CI de api, web y vr (runner del Mac Mini), después de que pasan los tests:
#       git -C ~/apps/grafo-tareas fetch -q origin main && git -C ~/apps/grafo-tareas show origin/main:deploy/desplegar-aqui.sh | bash -s
#     (se lee de origin/main para correr siempre la versión publicada del script, aunque el clon local vaya atrás)
#   · bin/desplegar desde el ThinkPad, por ssh: el camino a mano para una emergencia.
# Repetible: correrlo dos veces seguidas no cambia nada. Lo despliega todo junto, y lo que no cambió no se reconstruye.
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"   # ni ssh ni el LaunchAgent del runner cargan el .zshrc
# Sin la attestation de procedencia (lleva la hora del build) el mismo código da la misma imagen y `up --build` no
# recrea nada. Va por variable: compose 2.x construye con bake y no respeta `provenance: false` (medido 2026-10-17).
export BUILDX_NO_DEFAULT_ATTESTATIONS=1

DIR="$HOME/apps/${GRAFO_APP:-grafo-tareas}"                 # convención del Mac Mini: ~/apps/<app>
GITHUB="${GRAFO_GITHUB:-git@github.com:Freddymhs}"
RAMA=main
REPOS_INTERNOS="grafo-tareas.api grafo-tareas.web grafo-tareas.vr"
PUERTO_API=3007                                          # 127.0.0.1 del Mac Mini (lsof 2026-11-14: 3013+ libres)
PUERTO_WEB=3008
PUERTO_VR=3013
CONTENEDORES_ESPERADOS=5                                 # postgres, api, web, vr, respaldo
TAILSCALE=/Applications/Tailscale.app/Contents/MacOS/Tailscale
SEGUNDOS_ESPERA=180
CANDADO="$DIR.desplegando"                               # dos pushes a la vez (api y web) no corren compose juntos
SEGUNDOS_CANDADO=900

falla() { echo "desplegar: $*" >&2; exit 1; }
reintentar() {   # GitHub corta a veces el ssh (`Connection reset by peer`, 2026-10-17); bash 3.2 de macOS: sin mapfile
  for n in 1 2 3; do "$@" && return 0; echo "reintento $n/3: $*" >&2; sleep 5; done
  return 1
}
traer() {   # traer <dir> <repo>: clona la primera vez; después solo avanza (nunca pisa: --ff-only)
  if [ -d "$1/.git" ]; then
    reintentar git -C "$1" fetch -q origin "$RAMA"
    git -C "$1" checkout -q "$RAMA" && git -C "$1" merge -q --ff-only "origin/$RAMA"
  else reintentar git clone -q --branch "$RAMA" "$GITHUB/$2.git" "$1"; fi
  echo "$2 @ $(git -C "$1" rev-parse --short HEAD)"
}
desde_refs() {   # desde_refs <refs.yaml> <clave>: una clave de `despliegue:` (en el Mac Mini no está ~/bin/ref)
  awk -v clave="$2" '/^despliegue:/ {dentro=1; next} dentro && /^[^ #]/ {dentro=0}
    dentro && $1 == clave":" {print $2; exit}' "$1"
}

# El candado: mkdir es atómico (macOS no trae flock). Si otro despliegue corre, se espera; uno colgado se rompe a los 15 min.
fin_espera=$((SECONDS + SEGUNDOS_CANDADO))
until mkdir "$CANDADO" 2>/dev/null; do
  [ $SECONDS -lt $fin_espera ] || { echo "candado viejo en $CANDADO: lo rompo" >&2; rm -rf "$CANDADO"; continue; }
  echo "otro despliegue en curso; espero…"; sleep 10
done
trap 'rm -rf "$CANDADO"' EXIT

mkdir -p "$(dirname "$DIR")"
# La API lee roles.yaml y refs.yaml SOLO al arrancar: si el despliegue los cambia, hay que reiniciarla (abajo).
huella_area() { cat "$DIR/docs/roles.yaml" "$DIR/refs.yaml" 2>/dev/null | shasum | cut -c1-40; }
AREA_ANTES=$(huella_area)
traer "$DIR" grafo-tareas
for repo in $REPOS_INTERNOS; do traer "$DIR/$repo" "$repo"; done

URL_API=$(desde_refs "$DIR/refs.yaml" api); URL_WEB=$(desde_refs "$DIR/refs.yaml" web); URL_VR=$(desde_refs "$DIR/refs.yaml" vr)
[ -n "$URL_API" ] && [ -n "$URL_WEB" ] && [ -n "$URL_VR" ] || falla "faltan despliegue.api/web/vr en refs.yaml"
HTTPS_API="${URL_API##*:}"; HTTPS_WEB="${URL_WEB##*:}"; HTTPS_VR="${URL_VR##*:}"

ENV="$DIR/deploy/.env"
# deploy/.env es el `.env` que compose lee solo desde deploy/: así un `docker compose ps` a mano también funciona.
# La contraseña se crea una vez y se conserva; puertos y URLs se reescriben en cada despliegue (su fuente es este script).
CLAVE=$(sed -n 's/^POSTGRES_PASSWORD=//p' "$ENV" 2>/dev/null || true)
[ -n "$CLAVE" ] || { CLAVE=$(openssl rand -hex 24); echo "contraseña nueva de Postgres en deploy/.env"; }
umask 077
printf 'POSTGRES_PASSWORD=%s\nPUERTO_API=%s\nPUERTO_WEB=%s\nPUERTO_VR=%s\nURL_API=%s\nURL_WEB=%s\nURL_VR=%s\n' \
  "$CLAVE" "$PUERTO_API" "$PUERTO_WEB" "$PUERTO_VR" "$URL_API" "$URL_WEB" "$URL_VR" > "$ENV.nuevo" && mv "$ENV.nuevo" "$ENV"
umask 022
mkdir -p "$DIR/deploy/respaldos"

cd "$DIR/deploy"
docker compose up -d --build --remove-orphans 2>&1 | grep -vE '^ *#|^$' | tail -12
if [ "$AREA_ANTES" != "$(huella_area)" ]; then
  docker compose restart api >/dev/null 2>&1 && echo "roles.yaml o refs.yaml cambiaron: API reiniciada para leerlos"
fi

"$TAILSCALE" serve --bg --https="$HTTPS_API" "http://127.0.0.1:$PUERTO_API" >/dev/null
"$TAILSCALE" serve --bg --https="$HTTPS_WEB" "http://127.0.0.1:$PUERTO_WEB" >/dev/null
"$TAILSCALE" serve --bg --https="$HTTPS_VR" "http://127.0.0.1:$PUERTO_VR" >/dev/null

echo "--- contenedores (puerto publicado · reinicio)"
CONTENEDORES=$(docker compose ps -q)
set -- $CONTENEDORES   # contar con $# y no con `wc -w`: el wc de macOS rellena con espacios y "   4" ≠ "4"
[ $# = "$CONTENEDORES_ESPERADOS" ] || falla "se esperaban $CONTENEDORES_ESPERADOS contenedores corriendo y hay $#"
for c in $CONTENEDORES; do
  docker inspect -f '{{.Name}} · {{range $p, $b := .HostConfig.PortBindings}}{{range $b}}{{.HostIp}}:{{.HostPort}} {{end}}{{end}}· {{.HostConfig.RestartPolicy.Name}}' "$c"
  # D2 de la FASE 12 y la convención del Mac Mini: nada en la LAN, y todo vuelve solo tras un reinicio.
  ips=$(docker inspect -f '{{range $p, $b := .HostConfig.PortBindings}}{{range $b}}{{.HostIp}} {{end}}{{end}}' "$c")
  for ip in $ips; do [ "$ip" = 127.0.0.1 ] || falla "$c publica en $ip, no solo en 127.0.0.1"; done
  [ "$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$c")" = unless-stopped ] || falla "$c sin restart unless-stopped"
done

# Verificar por el tailnet: lo que ven el teléfono y el visor.
echo "--- verificación por el tailnet"
espera_200() {   # espera_200 <url>: reintenta hasta SEGUNDOS_ESPERA (la API aplica migraciones al arrancar)
  fin=$((SECONDS + SEGUNDOS_ESPERA)); codigo=000
  while [ $SECONDS -lt $fin ]; do
    codigo=$(curl -s -o /dev/null -m 10 -w '%{http_code}' "$1" || true)
    [ "$codigo" = 200 ] && break
    sleep 3
  done
  echo "$codigo"
}
cors_patch() {   # cors_patch <origen>: los métodos que el preflight permite desde ese origen
  curl -s -D - -o /dev/null -m 10 -X OPTIONS -H "Origin: $1" -H 'Access-Control-Request-Method: PATCH' \
    "$URL_API/api/v1/nodos" | tr -d '\r' | grep -i '^access-control-allow-methods:' || true
}
health=$(espera_200 "$URL_API/api/v1/health"); echo "API health: $health"
web=$(espera_200 "$URL_WEB/"); echo "PWA: $web"
vr=$(espera_200 "$URL_VR/"); echo "VR: $vr"
cors_web=$(cors_patch "$URL_WEB"); echo "CORS web: ${cors_web:-sin cabecera}"
cors_vr=$(cors_patch "$URL_VR"); echo "CORS vr: ${cors_vr:-sin cabecera}"

[ "$health" = 200 ] || falla "la API no responde 200 por $URL_API"
[ "$web" = 200 ] || falla "la PWA no responde 200 por $URL_WEB"
[ "$vr" = 200 ] || falla "la VR no responde 200 por $URL_VR"
case "$cors_web" in *PATCH*) ;; *) falla "el preflight no permite PATCH desde $URL_WEB (trampa CORS de la FASE 4)" ;; esac
case "$cors_vr" in *PATCH*) ;; *) falla "el preflight no permite PATCH desde $URL_VR: la VR no podría guardar posiciones" ;; esac
echo "listo: PWA $URL_WEB · VR $URL_VR · API $URL_API"
