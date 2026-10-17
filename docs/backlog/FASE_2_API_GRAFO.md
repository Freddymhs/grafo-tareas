# FASE 2: LA API DEL GRAFO — NODOS, CONEXIONES, RAMAS Y LO DERIVADO

**Destraba**: que el grafo tenga una fuente de verdad: la FASE 3 (importador) escribe en ella, la FASE 4 (PWA) y la FASE 6 (VR) la leen por Orval
**Listo para PR**: casi · 2026-10-16: tareas 1-5 hechas y verdes (tsc 0 · lint 0 · 17 unit · 11 e2e · build · grep agnóstico 0); falta el criterio 4 (correr en el Mac Mini contra Neon), que es despliegue y no código
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
- [x] Hecha — 2026-10-16: migración `20261017013307_grafo_inicial`; `(origenId, destinoId, tipo)` único; borrar un nodo borra sus conexiones (cascade). Base local: contenedor `grafo-tareas-postgres` en `127.0.0.1:5433` (Freddy: Docker ahora, Neon después)

### Tarea 2: módulos `nodos`, `conexiones`, `ramas`
- CRUD con DTOs `class-validator` y respuestas documentadas en Swagger. Una RAMA es un `Nodo` tipo RAMA con `color`; pertenecer = `PERTENECE_A`.
- [x] Hecha — 2026-10-16: `src/modules/{nodos,conexiones,ramas}`; `PUT nodos/posiciones` en lote y transacción (C2); `externo` único → 409 (C3); color solo en RAMA; una conexión no apunta a sí misma ni se repite
- [x] Tests unit (TestingModule, repos mockeados: 17) + e2e (`test/grafo.e2e-spec.ts`, el escenario del concepto: 11)

### Tarea 3: módulo `derivado`
- `GET /derivado/hoy-puedo`, `GET /nodos/:id/bloqueado`, `GET /nodos/:id/libera`. SQL recursivo con test de una cadena de 3 niveles y de un ciclo.
- [x] Hecha — 2026-10-16: `WITH RECURSIVE` (`UNION`, no `UNION ALL`: termina con ciclos) trae lo aguas abajo; `calcular-libera.ts` (función pura, punto fijo) separa `directos` de `cadena`. "Si Tomás contesta": libera la duda directo y 3 tareas en cadena, medido en e2e
- [x] Test rojo primero: `calcular-libera.spec.ts` 3/5 en rojo contra el stub, 5/5 después; el ciclo `A→B→A` responde 200 (e2e)

### Tarea 4: OpenAPI publicado y CI agnóstico
- El JSON de Swagger se exporta a un archivo versionado (lo consume Orval en las FASE 4 y 6). Paso de CI con el grep agnóstico.
- [x] Hecha — 2026-10-16: `pnpm openapi:export` (`src/openapi.ts` desde `dist`: ts-node no resuelve los alias `.js`) → `openapi.json` (10 rutas, determinista); el CI falla si quedó atrás (`git diff --exit-code`) y si `src/` nombra una herramienta fuera de `importadores/`

### Tarea 5: borrar `src/modules/example/` y su test
- [x] Hecha — 2026-10-16, con la migración `init` de la plantilla

## Criterios de Aceptación

- [x] 1 · `pnpm type-check`, `pnpm lint`, `pnpm test`, `pnpm test:e2e` en verde — 2026-10-16: 0 · 0 · 17/17 · 11/11
- [x] 2 · `hoyPuedo` y `libera` correctos — 2026-10-16: sobre el escenario del concepto (persona → duda → tareas, ciclo), en e2e; el generador sintético de la FASE 1 queda para la FASE 6, cuando la VR lea de la API
- [x] 3 · — 0 hits, y en el CI · `grep -rnE "sag\.laboratorio|Laboratorio/|dev\.azure|6VhFQg6v45qcJHPc|todoist" src` → 0 hits fuera de `importadores/`
- [ ] 4 · Corre en el Mac Mini (Docker) contra Neon y responde por Tailscale

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
