#!/usr/bin/env bash
# tracker-solo-lectura — PreToolUse sobre las herramientas de navegador de CUALQUIER MCP (`mcp__*__browser_*`).
# El tracker del cliente se lee, nunca se escribe (metodo.md §Git es de Freddy; PORTAR.md receta paso 6).
#
#   tracker declarado     → bloquea las que escriben (click, type, fill_form, drag, drop, select_option,
#                           press_key, file_upload, handle_dialog, run_code_unsafe, hover, navigate_back,
#                           tabs) y un browser_evaluate con método HTTP mutante o interacción DOM.
#                           Las de lectura (navigate, snapshot, screenshot, evaluate de un GET) pasan.
#   `tracker: none`       → no hay tracker que proteger (proyecto personal): pasa todo. Probar la web propia
#                           con el navegador no se bloquea.
#   clave ausente         → bloquea y dice cómo declararla: una ausencia no distingue "no hay" de "me olvidé".
#
# No depende del nombre del servidor MCP: la plantilla no lo sabe, y en el SAG se llama
# `playwright-extension-test`. Ahí la misma regla vive como `deny` + `browser-readonly.sh`.
set -uo pipefail
payload=$(cat)
leer() { printf '%s' "$payload" | python3 -I -c "import json,sys
try: d=json.load(sys.stdin)
except Exception: d={}
print($1)" 2>/dev/null; }
herramienta=$(leer "d.get('tool_name','')")
case "$herramienta" in mcp__*__browser_*) ;; *) exit 0 ;; esac
accion=${herramienta##*__browser_}

ORQ="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"
REF_DESDE="$ORQ" ref tracker >/dev/null 2>&1; rc=$?
case "$rc" in
  3) exit 0 ;;   # tracker: none
  0) ;;
  *) echo "BLOQUEADO: $herramienta — refs.yaml no declara \`tracker\`. Si este proyecto no tiene tracker de cliente, escribí \`tracker: none\`; si lo tiene, su bloque (PORTAR.md §El contrato del tracker)." >&2
     exit 2 ;;
esac

case "$accion" in
  click|type|fill_form|drag|drop|select_option|press_key|file_upload|handle_dialog|run_code_unsafe|hover|navigate_back|tabs)
    echo "BLOQUEADO: $herramienta — el tracker del cliente es SOLO LECTURA (.claude/hooks/tracker-solo-lectura.sh)." >&2
    exit 2 ;;
  evaluate)
    codigo=$(leer "d.get('tool_input',{}).get('function','')")
    if printf '%s' "$codigo" | grep -qiE "method\s*:\s*['\"](POST|PUT|PATCH|DELETE)|\.(submit|click)\s*\(|XMLHttpRequest|navigator\.sendBeacon"; then
      echo "BLOQUEADO: browser_evaluate con método HTTP mutante o interacción DOM — el tracker es SOLO LECTURA." >&2
      exit 2
    fi ;;
esac
exit 0
