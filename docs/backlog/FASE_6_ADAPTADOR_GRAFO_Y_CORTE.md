# FASE 6: ADAPTADOR `grafo` DEL TABLERO Y CORTE DE TODOIST

**Destraba**: que el método escriba en el grafo en vez de Todoist — `tablero.kind: grafo` y Todoist apagado para trabajo y proyectos
**Listo para PR**: no · FASE escrita el 2026-10-16
**Prioridad**: Media
**Dependencias**: **FASE 5** (la PWA reemplaza el uso diario) · FASE 3 (la migración)
**Fuente**: `docs/_CONCEPTO.md` § Cómo se conecta el grafo · `~/dotfiles/claude/PORTAR.md` §El contrato del tablero (5 operaciones)

> **Alcance:** método, no API. El adaptador vive en `bin/adapters/grafo/` de cada orquestador que lo use y cumple **el mismo
> contrato** que `Laboratorio/bin/adapters/todoist/`: `pendiente buscar tarjeta etapa borrador`, salida `<id>\t<content>`,
> exit ≠ 0 en error, exit 4 de `etapa` sin tarjeta. **Sin doble escritura:** el día del corte, Todoist deja de recibir.

## Understand

- [ ] Entendimiento — releer PORTAR §El contrato del tablero y los 6 `flow` que lo llaman

## Tareas

### Tarea 1: `bin/adapters/grafo/` con las 5 operaciones contra la API REST
- `pendiente bloqueo` = DUDA + `ESPERA_RESPUESTA_DE` a la PERSONA · `etapa` = estado del nodo FASE/TAREA. Backend falso para tests (como `TABLERO_FAKE`).
- [ ] Hecha
- [ ] Mismos 24 casos que `test_tablero.sh`, corridos contra este adaptador

### Tarea 2: migración final y corte
- Última corrida del importador (FASE 3) → `refs.yaml` `tablero: { kind: grafo, api, token_env }` en el Laboratorio y acá → Todoist solo para lo de N2.
- [ ] Hecha (con el OK de Freddy en el momento)

### Tarea 3: importadores de contexto — `FASE_*.md` + `entendimiento.md` §ABIERTO
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · `/flow:todo` y el hook `fase-tilde` escriben en el grafo sin cambiar una línea de los flows
- [ ] 2 · Segundo adaptador del contrato funcionando: cierra PORTAR §Huecos 4

## QA

- [x] Colección — no aplica: es CLI del método
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
