# FASE 3: IMPORTADOR TODOIST — UNA DIRECCIÓN, UNA VEZ, IDEMPOTENTE

**Destraba**: ver el trabajo real en el grafo: la FASE 4 (PWA) y la FASE 6 (VR) muestran datos de verdad y no sintéticos
**Listo para PR**: sí · commit `04cbbd6`, CI verde · 2026-10-16 (noche): tareas 1-3 y criterios 1-3 hechos; migración real a la base local hecha (134 tareas → 158 nodos, 86 conexiones; 2ª corrida 0 nuevos); `backlog:review` corrido y sus 3 errores corregidos. Falta: commit por `sellar` y la decisión de TestSprite (a/b/c) de Freddy
**Prioridad**: Alta
**Dependencias**: **FASE 2** (código verde 2026-10-16). N1, N2 y C1-C4 ya confirmados: **solo `TRABAJO`** (134 tareas), **nombres reales** de personas, base local en Docker
**Fuente**: `docs/_CONCEPTO.md` § Lo que Todoist no deja ver, § Fases F1.2, § Cómo se conecta el grafo (Migración), § Riesgos (importador frágil)

> **Alcance:** módulo `importadores/todoist` de `grafo-tareas.api` — **el único lugar del repo que nombra Todoist**. Lee, nunca
> escribe en Todoist. No es sincronización: corre una vez (y de nuevo sin duplicar, por `externo.id`).

## Understand

- [x] Entendimiento — 2026-10-16, `TRABAJO` completo por REST, solo lectura (134 tareas; 26 subtareas de 4 padres; 16 con fecha; 1 recurrente; 0 completadas en el export). Secciones: sin sección 42 · CERRADO 29 · 🔎 Precheck (archivadas) 25 · ENTENDIMIENTO 23 · DUDAS 4 · TESTEADO 3 · LISTO PARA PR 3 · PR 2 · AMARRAR 2 · APROBADO 1. Etiquetas: board 34 · propuesta 24 · retro 11 · daily 10 · supuesto 2. Prioridad p1 12 · p2 33 · p4 88.
  **Señales por tarea:** `[2xxxx]` Azure 50 · `FASE n` 38 (20 fases distintas) · PR 18 · círculos de color 26 (🟢16 🔵5 🟡3 🟣2 🟠1) · Tomás/Thomas 33 · Carabantes 14 · Fabián 9 · emoji de orden 6 · BLOQUEO/esperando a 4 (3 nombran a Tomás Carabantes) · **"Depende de" 0 y dudas W# 0**: esas vivían en el Draft, que quedó fuera (N2). El concepto § Lo que Todoist no deja ver se midió sobre 100 tareas y el Draft; estas son las cifras del alcance real.

## Las decisiones, y por qué (Freddy, 2026-10-16)

- **D1 · Tarea → nodo TAREA** con `externo {todoist, id}`, título = content tal cual (emojis de orden, `[2xxxx]` y PR incluidos: en v1 son texto). La descripción conserva lo que el grafo no modela, para no perder nada: sección, etiquetas, prioridad, fecha.
- **D2 · Estado:** CERRADO si la sección es `CERRADO` o `🔎 Precheck fin de sprint (archivadas)` (lista configurable) o la tarea está `checked`; el resto ABIERTO.
- **D3 · Subtareas:** el padre `DEPENDE_DE` cada hija — cerrar la última lo libera, y `libera` ya lo calcula.
- **D4 · Círculos de color → RAMA** por emoji (título = el emoji, color hex fijo); la tarea `PERTENECE_A` cada rama que lleve (🔵🟢 = dos ramas). Freddy las renombra en la PWA.
- **D5 · `FASE n` → nodo FASE "FASE n"** (uno por número) y la tarea `PERTENECE_A` esa FASE.
- **D6 · Personas:** solo cuando la tarea dice `BLOQUEO` o `esperando a` **y** nombra a alguien de la tabla de alias → nodo PERSONA + `ESPERA_RESPUESTA_DE`. Mencionar a Tomás en una descripción no es un bloqueo. Alias: Tomás · Thomas · Carabantes · Tomás Carabantes → "Tomás Carabantes"; Fabián → "Fabián" **(C8: confirmar que Tomás y Carabantes son la misma persona)**.
- **D7 · Emojis de orden 0️⃣…5️⃣: sin `DEPENDE_DE`** (6 tareas de contextos distintos darían dependencias falsas). Azure ids y PRs: texto, importadores de Azure/GitHub fuera de v1.
- **D8 · Nodos sintetizados (RAMA, FASE, PERSONA) también llevan `externo`** (`todoist` + `rama:🟢` / `fase:32` / `persona:tomas-carabantes`): así la reimportación es idempotente por construcción (índice único de la API).
- **D9 · Dentro del repo de la API**, módulo `src/importadores/todoist/` (único lugar que nombra Todoist): un cliente HTTP (paginado por `next_cursor`, el bug que Freddy ya sufrió), un **traductor puro** (tareas + secciones → plan de nodos y conexiones, con test sobre fixture real) y un servicio que aplica el plan con `upsert` por `externo`. `--seco` imprime el plan sin escribir.

## Tareas

### Tarea 1: fixtures reales anonimizados
- Fixture real reducido en `test/fixtures/todoist/` (tareas elegidas para cubrir D2-D7, descripciones recortadas). Nombres reales (N1); el repo es privado.
- [x] Hecha — 2026-10-16: 12 tareas y 3 secciones del export real (padre con 4 hijas, 2 BLOQUEO, 🔵🟢, FASE 32, 0️⃣, CERRADO/archivadas/ENTENDIMIENTO)

### Tarea 2: reglas de traducción, una por test
- Emojis de orden 0️⃣…5️⃣ → `DEPENDE_DE` · círculos 🔵🟢🟠🟣 → `PERTENECE_A` rama · `Depende de: 0.1, 0.2` → conexiones ·
  `esperando a <persona>` → PERSONA + `ESPERA_RESPUESTA_DE` · dudas `W#` → un solo nodo DUDA compartido · `[25327]`/PR/FASE → `externo`.
- [x] Hecha — 2026-10-16: `src/importadores/todoist/traducir.ts`, función pura; las reglas son D1-D8 (las del concepto que no aparecen en TRABAJO —"Depende de", W#— no se implementan: 0 casos)
- [x] Cada regla con su caso real del fixture: `traducir.spec.ts` 11/11 (D1-D8 + determinismo)

### Tarea 3: comando de importación
- `pnpm importar:todoist -- --proyecto <id> [--seco]`. `--seco` imprime qué crearía sin escribir. Dos corridas seguidas = 0 nodos nuevos.
- [x] Hecha — 2026-10-16: `cli.ts` (desde `dist`) + `ImportadorTodoistService` (plan aplicado en UNA transacción, upsert por `externo`) + `TodoistClient` (solo GET, paginado por `next_cursor`, 4 tests). **En seco contra TRABAJO real: 134 tareas → 158 nodos (134 + 5 ramas + 18 FASE + 1 persona) y 86 conexiones.** Trampa real: `fetch` como parámetro con default en el constructor → Nest intentaba inyectarlo y abortaba EN SILENCIO (`logger: false` + `abortOnError`); los tests no lo veían porque el e2e reemplaza el cliente y el unit lo construye a mano → token `FETCH` inyectable y `abortOnError: false` en el CLI

## Criterios de Aceptación

- [x] 1 · Idempotente: la segunda corrida crea 0 nodos y 0 conexiones — `test/importador.e2e-spec.ts` 3/3 contra la base de test
- [x] 2 · **Ajustado a lo medido y a D6:** solo las tareas que dicen BLOQUEO/esperando a cuelgan de una PERSONA (3 de Tomás Carabantes); mencionar a alguien (33 tareas nombran a Tomás) no es un bloqueo. Fabián no bloquea ninguna
- [x] 3 · Ninguna llamada de escritura a Todoist — el cliente no tiene método que no sea GET (`todoist.client.spec.ts` lo verifica)

## QA

- [x] Colección — no aplica: el importador es un comando, no expone rutas; lo cubre `test/importador.e2e-spec.ts`
- [x] Auditoría — `/work:backlog:review` 2026-10-16: ❌ `let cursor` en el cliente (→ paginación recursiva) · ❌ `let` en specs, también los 2 de la plantilla (→ `armar()` por test y holder `ctx` en e2e; 0 `let` en el repo) · ❌ los e2e se pisaban en la base de test (→ `maxWorkers: 1`) · ⚠️ `hoy-puedo` listaba nodos FASE: con datos reales 96 de 80 abiertas (→ solo TAREA, concepto § Modelo: 78 de 80, 2 padres bloqueados por subtareas). ⚠️ TestSprite no instalado: quality gate pendiente de decisión de Freddy
- [x] Listo para PR — commit `04cbbd6` en grafo-tareas.api, CI verde

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
