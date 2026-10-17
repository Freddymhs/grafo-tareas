# Backlog — grafo-tareas

**Última actualización:** 2026-10-16 · Fuente: [`../_CONCEPTO.md`](../_CONCEPTO.md) (generado con `/work:create-backlog`)

Proyecto personal, sin tracker de empresa (`refs.yaml`: `tracker: none`, `tablero: none`). Cada FASE abre con **Destraba**
y lleva `## Understand`, `## QA` y `## Cierre oficial en Azure` (esta última, *no aplica*: formato del método, `/work:resume:new-concept` §B).

## Fases

| FASE | Concepto | Destraba | Repo | Estado |
|---|---|---|---|---|
| [1 · Prueba en el visor](FASE_1_PRUEBA_VISOR.md) | F1.0 | la decisión del 3D, antes de escribir la API | `grafo-tareas.vr` | ✅ 72 FPS · DECISION_3D |
| [2 · API del grafo](FASE_2_API_GRAFO.md) | F1.1 | una fuente de verdad para importador, VR y PWA | `grafo-tareas.api` | 🟡 código verde · falta desplegar (criterio 4) |
| [3 · Importador Todoist](FASE_3_IMPORTADOR_TODOIST.md) | F1.2 | ver el trabajo real (pide N1, N2, C1-C4 confirmados) | `grafo-tareas.api` | 🟡 código verde, migración local hecha (134 tareas) · falta `Listo para PR` |
| [4 · PWA tipo lista](FASE_4_PWA_LISTA.md) | F2 | trabajar el día sin Todoist | `grafo-tareas.web` | ⬜ |
| [5 · Adaptador `grafo` y corte](FASE_5_ADAPTADOR_GRAFO_Y_CORTE.md) | F2 | `tablero.kind: grafo`, Todoist apagado | método (`bin/adapters/grafo/`) | ⬜ |
| [6 · VR solo lectura](FASE_6_VR_SOLO_LECTURA.md) | F1.3 | el mapa real en el visor: otra vista del mismo dato | `grafo-tareas.vr` | ⬜ |
| [7 · Editar desde el visor](FASE_7_EDITAR_DESDE_VR.md) | F3 | conectar y cerrar dentro del 3D | `grafo-tareas.vr` | ⬜ |

**Orden (Freddy, 2026-10-16, con la FASE 1 verde):** backend → clon de Todoist → corte → VR. La VR es otra vista de lo que muestra la PWA; el riesgo del 3D ya lo descartó la FASE 1. F4 del concepto (Redis + cola, OAuth) no tiene FASE: solo si hace falta.
**La FASE 1 corta:** si en el visor no rinde o no se lee, se para y se revisa la decisión del 3D antes de la FASE 2.

## Diagramas de Referencia

| Archivo | Tipo | Contenido |
|---------|------|-----------|
| `../diagrams/DIAGRAMAS_COMPONENTES.md` | Flowcharts | Topología del sistema |

Referencia estructural estable. Las fases lo referencian pero no lo repiten. Actualizar solo ante cambios de topología.

## Decisiones Técnicas

Carpeta `../decisions/` — decisiones arquitectónicas cuando surjan durante el desarrollo (la primera: `DECISION_3D.md`, al cerrar la FASE 1).
Formato: `DECISION_[TEMA].md` — explica el POR QUÉ, no el QUÉ.

## Validación de Flujos

| Archivo | Propósito |
|---------|-----------|
| `../flows.md` | Flujos de usuario documentados manualmente. Guía para QA y E2E. |

Llenar después de probar cada feature. Usar como referencia con `/tools:testing:run-browser-testing`.
