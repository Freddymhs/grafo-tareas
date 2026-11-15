# FASE 12: DESPLIEGUE EN EL MAC MINI — API, BASE Y PWA SIEMPRE ENCENDIDAS, SOLO POR EL TAILNET

**Destraba**: el corte de Todoist (FASE 5 tarea 2) y el criterio 4 de la FASE 2: el grafo deja de depender de que el PC esté prendido, y hay **una sola** base de verdad
**Listo para PR**: casi · 2026-10-17: desplegado y verificado desde el PC por el tailnet (tareas 1-4 ✅, 5 casi); falta lo de Freddy: abrir la PWA en el teléfono (criterio 1); los monitores de Uptime Kuma quedaron hechos el 2026-11-15 (FASE 27 (b))
**Prioridad**: Alta
**Dependencias**: FASE 2 (API), FASE 4 (PWA). Mac Mini: Docker 29.4 arm64, acceso a GitHub, `tailscale serve` con el 443 ya ocupado (proxy a `:18789`, no es nuestro)
**Fuente**: `docs/_CONCEPTO.md` § Stack (fila Despliegue: «API y fronts en el Mac Mini (Docker), acceso solo por Tailscale»), § Para confirmar N1 · reglas globales §9 (Docker)

> **Alcance:** la API, su Postgres y la PWA, en contenedores del Mac Mini, publicados **solo** por `tailscale serve` (HTTPS del
> tailnet). La VR no se despliega: `bin/probar-en-visor --api` pasa a hablar con la API del Mac Mini. Neon queda para después (N1).

## Las decisiones, y por qué

### D1 · Postgres en Docker en el Mac Mini, no Neon (Freddy, 2026-10-17)
N1 dejó «base local en Docker por ahora, revisar antes de subir a Neon»: los nombres reales del cliente no salen de máquinas de
Freddy. El cambio a Neon es una `DATABASE_URL`, no código.

### D2 · Nada se publica en la LAN
Postgres sin puerto publicado; API y PWA en `127.0.0.1` del Mac Mini, **3007 y 3008** (convención del `~/CLAUDE.md` del Mac Mini: apps generales en 3001-3009; 3001-3006 ya tomados).
Afuera solo `tailscale serve`, que solo ofrece HTTPS en 443, 8443 y 10000: **8443 → API, 10000 → PWA** (el 443 es de otro servicio). Nombre en el tailnet: `mac-mini-server.tail1798c7.ts.net` (el viejo `freddys-mac-mini` ya no resuelve). Sin Cloudflare: son datos del cliente.

### D3 · Una sola base de verdad
Los datos del PC (`grafo-tareas-postgres`, 5433) se copian **una vez** al Mac Mini (`pg_dump` → `pg_restore`). Desde ahí la base del
PC es de desarrollo: `bin/dev` y `bin/servir-tailnet` siguen sirviendo para probar código, no para trabajar.

### D4 · El despliegue es un comando repetible
`bin/desplegar` (orquestador, por ssh): el runner de GitHub del Mac Mini solo toma repos de `fmarcos-labs` y éstos son de `Freddymhs`. En el Mac Mini (`~/apps/grafo-tareas`, la convención del equipo) trae los repos a su `main` publicado, construye y levanta `deploy/compose.yml`,
aplica las migraciones (`prisma migrate deploy` al arrancar la API), configura `tailscale serve` y verifica health y CORS. Lo que
no está en GitHub no se despliega: por eso se pushea antes.

### D5 · Respaldo diario
Una vez que el grafo reemplaza a Todoist, perder la base es perder el trabajo. `pg_dump` diario, 14 copias, en un contenedor `respaldo` del mismo compose con `restart: unless-stopped`: el `~/CLAUDE.md` del Mac Mini registra que los LaunchAgents no siempre cargan en ese equipo headless, y un LaunchDaemon pide `sudo`.
Desde 2026-11-14 los dumps van a `~/respaldos/grafo-tareas` del Mac, la carpeta que el `lab-respaldo.timer` del ThinkPad copia entera cada día: antes quedaban solo en el disco del Mac, y si ese disco moría se perdían la base y sus respaldos juntos.

## Understand

- [x] Entendimiento — 2026-10-17: Mac Mini medido por ssh (Docker 29.4 arm64 con 10 contenedores, 20 GB libres + 17,7 GB de caché de build recuperable; `tailscale serve` 443 → `:18789`; GitHub accesible: `ls-remote` de la api = `8ae618c`)

## Tareas

### Tarea 1: imágenes que cumplen §9
- `grafo-tareas.api`: `.dockerignore` (`.env`, `.env.*`, `node_modules`, `dist`, `.git`…), `USER node`, pnpm fijado por `packageManager` (no `pnpm@latest`), migraciones al arrancar. `grafo-tareas.web`: `Dockerfile` (build con `NEXT_PUBLIC_API_URL` como argumento) y `.dockerignore`.
- [x] Hecha — 2026-10-17: api `3884047`, web `c76fc1f`
- [x] Las dos imágenes construyen y corren como usuario no-root — `id -un` = `node` en los dos contenedores del Mac Mini; sin `.env` adentro; el build de la web **falla** sin `NEXT_PUBLIC_API_URL` (probado en rojo)

### Tarea 2: `deploy/compose.yml` + `bin/desplegar`
- [x] Hecha — 2026-10-17: `deploy/compose.yml` (api, postgres, web, respaldo) y `bin/desplegar` (lee `refs.yaml` → `despliegue`; reintenta los cortes de GitHub)
- [x] Idempotente — dos corridas seguidas: 0 contenedores recreados. Tres tropiezos medidos (CLAUDE.md § Trampas): la attestation de BuildKit recreaba todo en cada corrida (`BUILDX_NO_DEFAULT_ATTESTATIONS=1`; `provenance: false` no sirve con bake), `wc -w` de macOS rellena con espacios, y las variables solo en el entorno rompían un `docker compose` a mano (ahora en `deploy/.env`)

### Tarea 3: los datos del PC al Mac Mini, una vez
- [x] Hecha — 2026-10-17: `pg_dump` del PC → `pg_restore` en el Mac Mini con la API detenida y la base vacía comprobada antes (guard). **PC 214 nodos · 137 conexiones · 2 migraciones · última edición 16:46:47 = Mac Mini, idéntico**; sha256 de la copia verificado

### Tarea 4: respaldo diario
- [x] Hecha — 2026-10-17: contenedor `respaldo` (`unless-stopped`, cada 24 h, 14 copias en `deploy/respaldos/`); forzado con datos reales (68 KB) y restaurado en `grafo_prueba_respaldo`: 214 · 137; la base de prueba se borró

### Tarea 5: los consumidores apuntan al Mac Mini
- `refs.yaml` (bloque `tablero` comentado, para el corte), `bin/probar-en-visor --api`, CLAUDE.md del orquestador, la tabla «Apps corriendo» del `~/CLAUDE.md` del Mac Mini y un monitor INTERNO en Uptime Kuma (checklist del Mac Mini, punto 12).
- [x] `refs.yaml` → `despliegue: { ssh, app, api, web }` (la fuente; el bloque `tablero` del corte apunta a `despliegue.api`) · `probar-en-visor --api` contra el Mac Mini (bundle con su URL, sin `adb reverse` del 3000; probado con adb falso) · CLAUDE.md del orquestador · `~/CLAUDE.md` del Mac Mini (fila nueva, respaldo `.antes-grafo-*`) · `tailscale serve` del PC apagado (sus rutas apuntaban a la API local, ya sin uso)
- [x] Monitores INTERNOS en Uptime Kuma — hecho 2026-11-15 (ver FASE 27 (b): API, web y VR cargados, con aviso al Telegram de Hermes). Antes quedaba para **Freddy**: agregados a la lista de `~/uptime-kuma-setup.py` (`grafo-api` → `http://host.docker.internal:3007/api/v1/health`, `grafo-web` → `:3008`, los dos alcanzables desde el contenedor, medido); crearlos pide su usuario de Kuma — en la UI son 2 monitores HTTP, o correr el script (ojo: borra y recrea todos)

## Criterios de Aceptación

- [ ] 1 · Desde el PC y desde el teléfono (tailnet): `GET https://<mac-mini>:8443/api/v1/health` = 200 y la PWA en `:10000` carga el tablero con los datos reales — **PC ✅ 2026-10-17** (Chrome: tablero con columnas, FASE y tarjetas reales, 0 errores de consola/CORS; los `ERR_ABORTED` eran prefetch de Next, su RSC directo da 200); **teléfono: Freddy**
- [x] 2 · Preflight `PATCH` desde `https://…:10000` → `GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS` (lo verifica `bin/desplegar` en cada corrida)
- [x] 3 · Desde la LAN `192.168.1.11:3007/3008/5432` → sin respuesta; control positivo: Home Assistant `:8123` → 200 (el chequeo puede fallar). Los 4 con `unless-stopped` (lo verifica `bin/desplegar`)
- [x] 4 · Medido con la API del PC apagada (nada en 3000/3001): la PWA del Mac Mini carga el tablero completo
- [x] 5 · `node` en api y web; `/app/.env` no existe en ninguna de las dos

## QA

- [x] Colección — no aplica: no agrega rutas; las existentes las cubren los e2e
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
