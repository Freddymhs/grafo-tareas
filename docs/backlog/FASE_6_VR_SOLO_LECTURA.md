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
- [ ] Hecha

### Tarea 2: posiciones persistidas
- Primera carga sin posición → layout (FASE 1, D4) → `PATCH` de las posiciones. Siguientes cargas leen la posición guardada: el mapa no cambia de un día a otro.
- [ ] Hecha

### Tarea 3: ramas y bloqueo desde la API
- Color por rama (`PERTENECE_A`); "qué lo bloquea" sale de `GET /nodos/:id/bloqueado`, no se calcula en el front (C1).
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · El grafo importado se ve en el visor a ≥ 72 FPS (el umbral de la FASE 1)
- [ ] 2 · Recargar dos veces da el mismo mapa
- [ ] 3 · Ninguna regla de bloqueo en el código del front (grep de `DEPENDE_DE` fuera de lo generado: 0)

## QA

- [x] Colección — no aplica: no expone API
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
