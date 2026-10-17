# FASE 4: LA PWA TIPO LISTA — LO QUE SE USA DE TODOIST, MÁS LO QUE NO PUEDE

**Destraba**: poder trabajar el día a día sin Todoist (la FASE 5 apaga Todoist solo si esto existe)
**Listo para PR**: no · FASE escrita el 2026-10-16
**Prioridad**: Media
**Dependencias**: **FASE 2** (OpenAPI) · FASE 3 (datos reales importados)
**Fuente**: `docs/_CONCEPTO.md` § Fases F2 (lo medido de Todoist), § Stack (PWA, Contrato)

> **Alcance:** `grafo-tareas.web/` (de `template-nextjs-tanstack`). **Solo lo que Freddy usa:** secciones por etapa, etiquetas
> `bloqueo`/`daily`/`propuesta`/`observacion`/`retro`, prioridades p1/p2, subtareas, pocas fechas, sin recurrentes. Más: ramas,
> bloqueos, "hoy puedo…", "si X contesta, se liberan N". Lo que nadie pide no se escribe.

## Understand

- [x] Entendimiento — 2026-10-16, medido en `TRABAJO` (134) y `🚀 Draft trabajo` (7), solo lectura, a pedido de Freddy ("revisa todo lo que tengo… ahí entiendes qué features requiere").
  **Cómo trabaja Freddy en Todoist:** el tablero son las **secciones** (TRABAJO: sin sección 42 = entrada · ENTENDIMIENTO 23 · DUDAS EN ESPERA 4 · AMARRAR 2 · TESTEADO 3 · LISTO PARA PR 3 · Pull Request 2 · APROBADO 1 · CERRADO 29 · Precheck archivadas 25; Draft: Entrada · carriles A/B/C · Esperan algo) · **descripciones largas en Markdown** (106 de 134 con texto, mediana 359 caracteres, máx 4603; en el Draft mediana 1970 con `#` títulos) · **etiquetas** board 34 · propuesta 24 · retro 11 · daily 10 · supuesto 2 · **prioridad** p1 12 · p2 33 · p4 88 · **fecha** solo 16 · **subtareas** 26 · ids de Azure en 50 títulos y PR en 18 (así las encuentra) · **cero** comentarios, deadlines, duraciones, asignados y recurrentes.
  **Lo que Freddy explicó (2026-10-17, con `fases.html` y `calidad.html` del Laboratorio):** el corazón son los `FASE_x.md`; esos HTML solo reflejan sus casillas y le sirven para "tarjetear" el mismo origen en dos tableros —flujo normal (entender → colección → auditoría → listo para PR → cierre) y calidad (amarrar → cambiar → red → PR)— y verlo todo a la vez, porque no tiene un entorno 3D. Todoist suma lo que esos archivos no muestran: **las conexiones** (qué tarjeta se relaciona con cuál y qué la desbloquea), las tarjetas tipo daily / observación / propuesta, y una columna de "cosas que no se pueden olvidar" que en realidad son relaciones escritas en prosa: eso, en el grafo, es una conexión visible, y ahí entra el 3D. El Draft está en **columnas (carriles)** para avanzar varias partes de un proyecto en paralelo y ver qué avanza y en qué orden. → Para el grafo: los nodos FASE deben nacer de los `FASE_x.md` con su etapa derivada de las casillas, como hace `bin/fases` (importador de contexto, FASE 5), y los carriles son ramas/etapas paralelas de una HISTORIA.
  **Lo que la PWA necesita (y la API aún no tiene):** `etapa`, `etiquetas`, `prioridad`, `vence` en el nodo (hoy el importador los deja escritos en la descripción) y búsqueda por texto → **C9 ✅ confirmado 2026-10-17:** los 4 campos, etapas = lista fija (las del método, `tablero.secciones`), y búsqueda `GET nodos?q=`. Implementado en la API (migración `tablero_etapa_etiquetas_prioridad_vence`, `GET /etapas`, filtros `etapa`/`etiqueta`/`q`); el importador llena los 4 campos. Pantallas: tablero por etapa (sin etapa = entrada) · hoy puedo · bloqueos y personas (qué se libera) · ramas · detalle con Markdown, etiquetas, prioridad, fecha y subtareas · crear/cerrar/conectar · buscar.

## Tareas

### Tarea 1: Orval + borrar la demo `posts/` de la plantilla
- [x] Hecha — 2026-10-16: `orval.config.ts` (react-query + fetch, tags-split, mutator `src/lib/api/cliente.ts` que apunta a `NEXT_PUBLIC_API_URL` y desenvuelve el sobre `{data, meta}` de la API) → `src/lib/api/generado/` (`pnpm api:generar`); demo `posts/`, `table/`, store, schemas y query-keys fuera; home/layout/e2e del proyecto; `@serwist/next` instalado para la tarea 4

### Tarea 2: vistas — "hoy puedo", por rama, por persona que bloquea
- [ ] Hecha

### Tarea 3: crear / cerrar / conectar nodos
- [ ] Hecha

### Tarea 4: Serwist (offline de lectura) + manifest; abrir por URL de Tailscale en el teléfono y en el Quest
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · Una semana de trabajo real hecha desde la PWA sin abrir Todoist
- [ ] 2 · Gates de la plantilla en verde (type-check, lint, vitest, playwright)
- [ ] 3 · Hidratación sin warnings (gap de entrevista: concepto § practice-wishlist)

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
