# FASE 6: VR SOLO LECTURA CONTRA LA API — EL MAPA DE VERDAD

**Destraba**: el entregable de F1 (concepto § Fases): Freddy ve su trabajo real como red dentro del visor, con qué bloquea a qué
**Listo para PR**: no · FASE escrita el 2026-10-16
**Prioridad**: Alta
**Dependencias**: **FASE 1** (la escena), **FASE 2** (OpenAPI), **FASE 3** (datos reales)
**Fuente**: `docs/_CONCEPTO.md` § Fases F1.3, § Stack (Contrato, Layout 3D)

## Understand

- [x] Entendimiento — no aplica: FASE técnica

## Tareas

### Tarea 1: Orval en `grafo-tareas.vr`
- `orval.config.ts` lee el OpenAPI exportado de la API → tipos + hooks TanStack Query generados. El generador sintético queda solo para tests.
- [x] Hecha — 2026-10-17: `@tanstack/react-query` 5.100.1 y `orval` 8.43.0 (las versiones de la web) · `orval.config.ts` igual al de la web (`../grafo-tareas.api/openapi.json`, fetch, tags-split) · `src/lib/api/cliente.ts` (mutator que desenvuelve `{data, meta}`, `VITE_API_URL`, default `localhost:3000`) · `npm run api:generar` → `src/lib/api/generado/`. El sintético queda para la medición de la FASE 1: solo con `?nodos=` o `?sintetico`; sin query, el grafo real (`lib/parametros.ts`, `FuenteGrafo`).

### Tarea 2: posiciones persistidas
- Primera carga sin posición → layout (FASE 1, D4) → `PATCH` de las posiciones. Siguientes cargas leen la posición guardada: el mapa no cambia de un día a otro.
- [x] Hecha — 2026-10-17: `escena/useMapaApi.ts` — mapa vacío → layout de fuerzas en el Worker → **un** `PUT /nodos/posiciones` con todas; con posiciones guardadas → se usan tal cual y los nodos nuevos caen junto al centro de sus vecinos ya ubicados, o en un punto fijo de la esfera si no tienen (`lib/ubicar.ts`, determinista por hash FNV del id, sin `Math.random`) → `PUT` solo de esos. Probado contra la API real: 1ª carga `PUT` de 165 de 165, 2ª carga 0 `PUT`.

### Tarea 3: ramas y bloqueo desde la API
- Color por rama (`PERTENECE_A`); "qué lo bloquea" sale de `GET /nodos/:id/bloqueado`, no se calcula en el front (C1).
- [x] Hecha — 2026-10-17: `lib/bloqueo.ts` borrado y `CONEXIONES_BLOQUEANTES` fuera de `dominio.ts`; `SeleccionConBloqueo` pregunta a `GET /nodos/:id/bloqueado` (probado: tocar a «Persona A» → "Libre: nada lo bloquea", 200). Color por rama desde el `color` de los nodos RAMA de la API. Con datos reales aparecieron dos defectos de lectura en 3D y se arreglaron: los emojis de los títulos (2️⃣, 🔵) salían como cajas y los títulos de 200 caracteres cruzaban la escena → `lib/texto-visible.ts` (sin pictogramas, 48 caracteres en la etiqueta, 120 en la selección).

## Criterios de Aceptación

- [ ] 1 · El grafo importado se ve en el visor a ≥ 72 FPS (el umbral de la FASE 1) — **lo mide Freddy con el visor puesto**: `bin/probar-en-visor --api --abrir` (API corriendo). Indicio: son 165 nodos y la FASE 1 sostuvo 72 FPS con 500.
- [x] 2 · Recargar dos veces da el mismo mapa — 2026-10-17: la 2ª carga no manda `PUT` y lee las 165 posiciones guardadas; `ubicar.test.ts` prueba que dos ubicaciones dan lo mismo y que con todo guardado no hay nada que guardar; e2e `grafo-api.spec.ts` con la API simulada
- [x] 3 · Ninguna regla de bloqueo en el código del front (grep de `DEPENDE_DE` fuera de lo generado: 0) — 2026-10-17: fuera de lo generado, los tests, el generador sintético (`sintetico.ts` y sus constantes) y la enumeración de tipos (`dominio.ts`): 0. El panel de la FASE 7 nombra los tipos para *crear* conexiones, no para decidir bloqueos

## QA

- [x] Colección — no aplica: no expone API
- [x] Auditoría — 2026-10-17: gates (tsc · lint · prettier · vitest 30 · build · playwright 3/3) y smoke con Chrome contra la API real
- [x] Listo para PR — 2026-10-17: commit `954652d` en `main` de `grafo-tareas.vr` (junto con la FASE 7); pusheado el 2026-10-17 y CI de GitHub verde

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
