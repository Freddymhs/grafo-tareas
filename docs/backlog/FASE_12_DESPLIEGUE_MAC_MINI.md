# FASE 12: DESPLIEGUE EN EL MAC MINI — API, BASE Y PWA SIEMPRE ENCENDIDAS, SOLO POR EL TAILNET

**Destraba**: el corte de Todoist (FASE 5 tarea 2) y el criterio 4 de la FASE 2: el grafo deja de depender de que el PC esté prendido, y hay **una sola** base de verdad
**Listo para PR**: no · FASE escrita el 2026-10-17 (Freddy: «Mac Mini + Postgres Docker», Neon después; «el corte, después del deploy»)
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

## Understand

- [x] Entendimiento — 2026-10-17: Mac Mini medido por ssh (Docker 29.4 arm64 con 10 contenedores, 20 GB libres + 17,7 GB de caché de build recuperable; `tailscale serve` 443 → `:18789`; GitHub accesible: `ls-remote` de la api = `8ae618c`)

## Tareas

### Tarea 1: imágenes que cumplen §9
- `grafo-tareas.api`: `.dockerignore` (`.env`, `.env.*`, `node_modules`, `dist`, `.git`…), `USER node`, pnpm fijado por `packageManager` (no `pnpm@latest`), migraciones al arrancar. `grafo-tareas.web`: `Dockerfile` (build con `NEXT_PUBLIC_API_URL` como argumento) y `.dockerignore`.
- [ ] Hecha
- [ ] Las dos imágenes construyen y corren como usuario no-root

### Tarea 2: `deploy/compose.yml` + `bin/desplegar`
- [ ] Hecha
- [ ] `bin/desplegar` corrido dos veces seguidas: la segunda no cambia nada (idempotente)

### Tarea 3: los datos del PC al Mac Mini, una vez
- [ ] Hecha — conteo de nodos y conexiones igual en las dos bases

### Tarea 4: respaldo diario
- [ ] Hecha — un respaldo corrido a mano y restaurado en una base de prueba

### Tarea 5: los consumidores apuntan al Mac Mini
- `refs.yaml` (bloque `tablero` comentado, para el corte), `bin/probar-en-visor --api`, CLAUDE.md del orquestador, la tabla «Apps corriendo» del `~/CLAUDE.md` del Mac Mini y un monitor INTERNO en Uptime Kuma (checklist del Mac Mini, punto 12).
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · Desde el PC y desde el teléfono (tailnet): `GET https://<mac-mini>:8443/api/v1/health` = 200 y la PWA en `:10000` carga el tablero con los datos reales
- [ ] 2 · El preflight `OPTIONS` con `PATCH` desde el origen de la PWA devuelve el método permitido (trampa CORS de la FASE 4)
- [ ] 3 · Nada escucha en la LAN del Mac Mini: 3007/3008 solo en `127.0.0.1`, Postgres sin puerto; los cuatro contenedores con `restart: unless-stopped`
- [ ] 4 · Con el PC apagado (o `bin/dev --parar`) la PWA sigue andando
- [ ] 5 · Los contenedores corren como no-root y la imagen no trae `.env`

## QA

- [x] Colección — no aplica: no agrega rutas; las existentes las cubren los e2e
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
