# FASE 2: LA API DEL GRAFO — NODOS, CONEXIONES, RAMAS Y LO DERIVADO

**Destraba**: que el grafo tenga una fuente de verdad: la FASE 3 (importador) escribe en ella, la FASE 4 (PWA) y la FASE 6 (VR) la leen por Orval
**Listo para PR**: no · FASE escrita el 2026-10-16; se detalla con `archivo:línea` al tomarla
**Prioridad**: Alta
**Dependencias**: **FASE 1 verde** (`DECISION_3D.md` dice que sigue R3F). Sin eso, esta FASE no arranca
**Fuente**: `docs/_CONCEPTO.md` § Modelo de dominio, § Stack (Backend, Plantilla API, Neon, Contrato), § Para confirmar C1-C3

> **Alcance:** `grafo-tareas.api/` (de `template-nest`). Monolito modular: un módulo por dominio. **La API no conoce ninguna
> herramienta**: ni Todoist, ni Azure, ni el SAG — el grep de § Prueba de que sigue agnóstico corre en el CI desde esta FASE.

## Lo que ya existe — no rehacer

- `template-nest`: Fastify, Swagger, Prisma 7 + `adapter-pg`, `base.repository.ts`, filtros/interceptores/pipes en `src/common/`,
  `health/`, pino, Docker, CI. El módulo `src/modules/example/` es la referencia de forma (controller → service → repository + DTOs + spec).

## Las decisiones, y por qué

- **D1 · Lo derivado se calcula en la API (C1).** `bloqueado`, `hoyPuedo`, `libera` en el módulo `derivado`, con `WITH RECURSIVE`
  sobre `Conexion`. Los fronts solo lo reciben: con tres repos, una regla duplicada se desincroniza.
- **D2 · `posicion {x,y,z}` vive en `Nodo` (C2).** El mapa 3D es estable entre sesiones.
- **D3 · `externo { origen, id }` único (C3).** Texto libre en `origen`; índice único compuesto. Todo importador es idempotente por ahí.
- **D4 · Neon, por `DATABASE_URL` en `.env`** (nunca en el repo). Local de desarrollo: el `docker-compose.yml` de la plantilla.

## Understand

- [x] Entendimiento — no aplica: FASE técnica; el entendimiento es `docs/_CONCEPTO.md` § Modelo de dominio

## Tareas

### Tarea 1: esquema Prisma y migración
- `prisma/schema.prisma`: `Nodo`, `Conexion`, enums `TipoNodo` / `TipoConexion` / `EstadoNodo`; índices por `origenId`, `destinoId`, `(externoOrigen, externoId)` único.
  Reemplaza la migración `init` y el modelo de ejemplo de la plantilla.
- [ ] Hecha

### Tarea 2: módulos `nodos`, `conexiones`, `ramas`
- CRUD con DTOs `class-validator` y respuestas documentadas en Swagger. Una RAMA es un `Nodo` tipo RAMA con `color`; pertenecer = `PERTENECE_A`.
- [ ] Hecha
- [ ] Tests unit (TestingModule) + e2e (Supertest)

### Tarea 3: módulo `derivado`
- `GET /derivado/hoy-puedo`, `GET /nodos/:id/bloqueado`, `GET /nodos/:id/libera`. SQL recursivo con test de una cadena de 3 niveles y de un ciclo.
- [ ] Hecha
- [ ] Test rojo primero: un ciclo `A→B→A` no cuelga la consulta

### Tarea 4: OpenAPI publicado y CI agnóstico
- El JSON de Swagger se exporta a un archivo versionado (lo consume Orval en las FASE 4 y 6). Paso de CI con el grep agnóstico.
- [ ] Hecha

### Tarea 5: borrar `src/modules/example/` y su test
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · `pnpm type-check`, `pnpm lint`, `pnpm test`, `pnpm test:e2e` en verde
- [ ] 2 · `hoyPuedo` y `libera` correctos sobre el grafo sintético de la FASE 1 (mismo generador como fixture)
- [ ] 3 · `grep -rnE "sag\.laboratorio|Laboratorio/|dev\.azure|6VhFQg6v45qcJHPc|todoist" src` → 0 hits fuera de `importadores/`
- [ ] 4 · Corre en el Mac Mini (Docker) contra Neon y responde por Tailscale

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
