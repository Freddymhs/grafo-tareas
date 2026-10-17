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

- [ ] Entendimiento — qué vistas de Todoist abre Freddy cada día (medir antes de diseñar pantallas)

## Tareas

### Tarea 1: Orval + borrar la demo `posts/` de la plantilla
- [ ] Hecha

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
