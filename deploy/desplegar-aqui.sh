#!/usr/bin/env bash
# desplegar-aqui.sh — FASE 27: corre EN el Mac Mini y deja en producción el `main` publicado de grafo-tareas
# (orquestador, api, web y vr) con deploy/compose.yml. Lo llaman dos caminos, con el mismo código:
#   · el job `deploy` del CI de api, web y vr (runner del Mac Mini), después de que pasan los tests:
#       git -C ~/apps/grafo-tareas fetch -q origin main && git -C ~/apps/grafo-tareas show origin/main:deploy/desplegar-aqui.sh \
#         | GRAFO_REPO=<repo que disparó> GRAFO_SHA=<su commit> bash -s
#     (se lee de origin/main para correr siempre la versión publicada del script, aunque el clon local vaya atrás)
#   · bin/desplegar desde el ThinkPad, por ssh: el camino a mano para una emergencia.
# Repetible: correrlo dos veces seguidas no cambia nada. Lo que no cambió no se reconstruye. El repo que disparó el CI avanza
# a SU commit (el que pasó los tests); el orquestador, a origin/main; los otros repos se quedan como estaban (ver GRAFO_REPO).
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"   # ni ssh ni el LaunchAgent del runner cargan el .zshrc
# Sin la attestation de procedencia (lleva la hora del build) el mismo código da la misma imagen y `up --build` no
# recrea nada. Va por variable: compose 2.x construye con bake y no respeta `provenance: false` (medido 2026-10-17).
export BUILDX_NO_DEFAULT_ATTESTATIONS=1
# El ayudante de credenciales de Docker Desktop (`credsStore: desktop`) se cuelga fuera de la sesión de Freddy: desde el
# LaunchAgent del runner el build quedó 35 min en `load metadata` y murió con «error getting credentials» (2026-11-14).
# Las imágenes base son públicas: el deploy usa una config sin ayudante, con los mismos plugins (compose, buildx).
DOCKER_SIN_AYUDANTE="$HOME/.docker-despliegue"
mkdir -p "$DOCKER_SIN_AYUDANTE"
printf '{"auths":{}}\n' > "$DOCKER_SIN_AYUDANTE/config.json"
ln -sfn "$HOME/.docker/cli-plugins" "$DOCKER_SIN_AYUDANTE/cli-plugins"
export DOCKER_CONFIG="$DOCKER_SIN_AYUDANTE" DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"

DIR="$HOME/apps/${GRAFO_APP:-grafo-tareas}"                 # convención del Mac Mini: ~/apps/<app>
GITHUB="${GRAFO_GITHUB:-git@github.com:Freddymhs}"
RAMA=main
REPOS_INTERNOS="grafo-tareas.api grafo-tareas.web grafo-tareas.vr"
# Qué commit pidió este despliegue (FASE 27 (a)): el job de api, web o vr pasa su repo y su sha, y SOLO ese repo avanza a ese
# commit; los otros dos se quedan como están. Sin esto, un commit con test rojo en un repo salía con el push verde de otro.
# Vacío = uso a mano (bin/desplegar): los tres avanzan a origin/main.
GRAFO_REPO="${GRAFO_REPO:-}"; GRAFO_SHA="${GRAFO_SHA:-}"
PUERTO_API=3007                                          # 127.0.0.1 del Mac Mini (lsof 2026-11-14: 3013+ libres)
PUERTO_WEB=3008
PUERTO_VR=3013
CONTENEDORES_ESPERADOS=5                                 # postgres, api, web, vr, respaldo
TAILSCALE=/Applications/Tailscale.app/Contents/MacOS/Tailscale
SEGUNDOS_ESPERA=180
CANDADO="$DIR.desplegando"                               # dos pushes a la vez (api y web) no corren compose juntos

falla() { echo "desplegar: $*" >&2; exit 1; }
reintentar() {   # GitHub corta a veces el ssh (`Connection reset by peer`, 2026-10-17); bash 3.2 de macOS: sin mapfile
  for n in 1 2 3; do "$@" && return 0; echo "reintento $n/3: $*" >&2; sleep 5; done
  return 1
}
traer() {   # traer <dir> <repo> [<meta>]: clona la primera vez; después solo avanza (nunca pisa: --ff-only) a <meta> (def. origin/main)
  if [ -d "$1/.git" ]; then
    reintentar git -C "$1" fetch -q origin "$RAMA"
    git -C "$1" checkout -q "$RAMA" && git -C "$1" merge -q --ff-only "${3:-origin/$RAMA}"
  else reintentar git clone -q --branch "$RAMA" "$GITHUB/$2.git" "$1"; fi
  echo "$2 @ $(git -C "$1" rev-parse --short HEAD)"
}
desde_refs() {   # desde_refs <refs.yaml> <clave>: una clave de `despliegue:` (en el Mac Mini no está ~/bin/ref)
  awk -v clave="$2" '/^despliegue:/ {dentro=1; next} dentro && /^[^ #]/ {dentro=0}
    dentro && $1 == clave":" {print $2; exit}' "$1"
}

mkdir -p "$(dirname "$DIR")"   # antes del candado: su `mkdir` (sin -p) falla siempre si ~/apps no existe y el `until` esperaría para siempre
# El candado: mkdir es atómico (macOS no trae flock) y guarda el pid de su dueño. Se espera mientras el dueño viva, sin
# reloj: con 15 min fijos, el primer build (35 min) dejó a web y vr romperlo y correr tres composes juntos (2026-11-14).
# Un dueño muerto (job cancelado, Mac reiniciado) no deja el candado tomado. El tope lo pone `timeout-minutes` del job.
until mkdir "$CANDADO" 2>/dev/null; do
  dueno=$(cat "$CANDADO/pid" 2>/dev/null || true)
  if [ -n "$dueno" ] && ! kill -0 "$dueno" 2>/dev/null; then
    echo "candado de un despliegue que ya no corre (pid $dueno): lo libero" >&2; rm -rf "$CANDADO"; continue
  fi
  echo "otro despliegue en curso (pid ${dueno:-?}); espero…"; sleep 10
done
echo $$ > "$CANDADO/pid"
trap 'rm -rf "$CANDADO"' EXIT

# La API lee roles.yaml y refs.yaml SOLO al arrancar: si el despliegue los cambia, hay que reiniciarla (abajo).
# Tolerante: la primera vez $DIR no existe y `cat` falla; con pipefail eso mataba el script en silencio (huella de vacío).
huella_area() { { cat "$DIR/docs/roles.yaml" "$DIR/refs.yaml" 2>/dev/null || true; } | shasum | cut -c1-40; }
AREA_ANTES=$(huella_area)
if [ -n "$GRAFO_REPO" ]; then
  case " grafo-tareas $REPOS_INTERNOS " in *" $GRAFO_REPO "*) ;; *) falla "GRAFO_REPO desconocido: $GRAFO_REPO" ;; esac
  [ -n "$GRAFO_SHA" ] || falla "GRAFO_REPO=$GRAFO_REPO sin GRAFO_SHA"
fi
traer "$DIR" grafo-tareas   # el orquestador (compose, este script, refs.yaml) siempre avanza a origin/main
for repo in $REPOS_INTERNOS; do
  if [ -z "$GRAFO_REPO" ]; then traer "$DIR/$repo" "$repo"
  elif [ "$repo" = "$GRAFO_REPO" ]; then traer "$DIR/$repo" "$repo" "$GRAFO_SHA"
  elif [ -d "$DIR/$repo/.git" ]; then echo "$repo @ $(git -C "$DIR/$repo" rev-parse --short HEAD) (sin avanzar)"
  else traer "$DIR/$repo" "$repo"; fi   # nunca clonado: no hay nada que "dejar como está"
done

URL_API=$(desde_refs "$DIR/refs.yaml" api); URL_WEB=$(desde_refs "$DIR/refs.yaml" web); URL_VR=$(desde_refs "$DIR/refs.yaml" vr)
[ -n "$URL_API" ] && [ -n "$URL_WEB" ] && [ -n "$URL_VR" ] || falla "faltan despliegue.api/web/vr en refs.yaml"
HTTPS_API="${URL_API##*:}"; HTTPS_WEB="${URL_WEB##*:}"; HTTPS_VR="${URL_VR##*:}"

ENV="$DIR/deploy/.env"
# deploy/.env es el `.env` que compose lee solo desde deploy/: así un `docker compose ps` a mano también funciona.
# La contraseña se crea una vez y se conserva; puertos y URLs se reescriben en cada despliegue (su fuente es este script).
CLAVE=$(sed -n 's/^POSTGRES_PASSWORD=//p' "$ENV" 2>/dev/null || true)
[ -n "$CLAVE" ] || { CLAVE=$(openssl rand -hex 24); echo "contraseña nueva de Postgres en deploy/.env"; }
# Los dumps van a ~/respaldos/, la carpeta que el ThinkPad copia cada día (lab-respaldo.timer): fuera del Mac (D5).
DIR_RESPALDOS="$HOME/respaldos/grafo-tareas"
umask 077
printf 'POSTGRES_PASSWORD=%s\nPUERTO_API=%s\nPUERTO_WEB=%s\nPUERTO_VR=%s\nURL_API=%s\nURL_WEB=%s\nURL_VR=%s\nDIR_RESPALDOS=%s\n' \
  "$CLAVE" "$PUERTO_API" "$PUERTO_WEB" "$PUERTO_VR" "$URL_API" "$URL_WEB" "$URL_VR" "$DIR_RESPALDOS" > "$ENV.nuevo" && mv "$ENV.nuevo" "$ENV"
umask 022
mkdir -p "$DIR_RESPALDOS"
# Una sola vez: los dumps que quedaron en la ruta vieja pasan a la nueva.
for viejo in "$DIR"/deploy/respaldos/grafo-*.dump; do [ -e "$viejo" ] && mv -n "$viejo" "$DIR_RESPALDOS/"; done

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
cors_preflight() {   # cors_preflight <origen>: las cabeceras de la respuesta al preflight de PATCH desde ese origen
  curl -s -D - -o /dev/null -m 10 -X OPTIONS -H "Origin: $1" -H 'Access-Control-Request-Method: PATCH' \
    "$URL_API/api/v1/nodos" | tr -d '\r' || true
}
cabecera() {   # cabecera <respuesta> <nombre>: el valor de la primera cabecera con ese nombre (sin importar mayúsculas)
  printf '%s\n' "$1" | awk -v nombre="$2" 'BEGIN { nombre = tolower(nombre) }
    { corte = index($0, ":") }
    !visto && corte > 0 && tolower(substr($0, 1, corte - 1)) == nombre {
      valor = substr($0, corte + 1); gsub(/^ +| +$/, "", valor); print valor; visto = 1 }'
}
health=$(espera_200 "$URL_API/api/v1/health"); echo "API health: $health"
web=$(espera_200 "$URL_WEB/"); echo "PWA: $web"
vr=$(espera_200 "$URL_VR/"); echo "VR: $vr"
respuesta_cors_web=$(cors_preflight "$URL_WEB")
cors_web=$(cabecera "$respuesta_cors_web" access-control-allow-methods)
origen_web=$(cabecera "$respuesta_cors_web" access-control-allow-origin)
echo "CORS web: métodos ${cors_web:-sin cabecera} · origen ${origen_web:-sin cabecera}"
respuesta_cors_vr=$(cors_preflight "$URL_VR")
cors_vr=$(cabecera "$respuesta_cors_vr" access-control-allow-methods)
origen_vr=$(cabecera "$respuesta_cors_vr" access-control-allow-origin)
echo "CORS vr: métodos ${cors_vr:-sin cabecera} · origen ${origen_vr:-sin cabecera}"

[ "$health" = 200 ] || falla "la API no responde 200 por $URL_API"
[ "$web" = 200 ] || falla "la PWA no responde 200 por $URL_WEB"
[ "$vr" = 200 ] || falla "la VR no responde 200 por $URL_VR"
case "$cors_web" in *PATCH*) ;; *) falla "el preflight no permite PATCH desde $URL_WEB (trampa CORS de la FASE 4)" ;; esac
[ "$origen_web" = "$URL_WEB" ] || falla "el preflight desde $URL_WEB devuelve access-control-allow-origin '${origen_web:-vacío}': el navegador lo bloquearía"
case "$cors_vr" in *PATCH*) ;; *) falla "el preflight no permite PATCH desde $URL_VR: la VR no podría guardar posiciones" ;; esac
[ "$origen_vr" = "$URL_VR" ] || falla "el preflight desde $URL_VR devuelve access-control-allow-origin '${origen_vr:-vacío}': el navegador lo bloquearía"
echo "listo: PWA $URL_WEB · VR $URL_VR · API $URL_API"
