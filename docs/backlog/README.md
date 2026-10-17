# Backlog — grafo-tareas

**Última actualización:** 2026-10-17 · Fuente: [`../_CONCEPTO.md`](../_CONCEPTO.md) (generado con `/work:create-backlog`)

Proyecto personal, sin tracker de empresa (`refs.yaml`: `tracker: none`, `tablero: none`). Cada FASE abre con **Destraba**
y lleva `## Understand`, `## QA` y `## Cierre oficial en Azure` (esta última, *no aplica*: formato del método, `/work:resume:new-concept` §B).

## Fases

| FASE | Concepto | Destraba | Repo | Estado |
|---|---|---|---|---|
| [1 · Prueba en el visor](FASE_1_PRUEBA_VISOR.md) | F1.0 | la decisión del 3D, antes de escribir la API | `grafo-tareas.vr` | ✅ 72 FPS · DECISION_3D |
| [2 · API del grafo](FASE_2_API_GRAFO.md) | F1.1 | una fuente de verdad para importador, VR y PWA | `grafo-tareas.api` | ✅ desplegada en el Mac Mini (FASE 12) |
| [3 · Importador Todoist](FASE_3_IMPORTADOR_TODOIST.md) | F1.2 | ver el trabajo real (pide N1, N2, C1-C4 confirmados) | `grafo-tareas.api` | ✅ importado (134 tareas → 158 nodos) · `04cbbd6` |
| [4 · PWA tipo lista](FASE_4_PWA_LISTA.md) | F2 | trabajar el día sin Todoist | `grafo-tareas.web` | ✅ 4/4 · offline, Markdown, servida por HTTPS del tailnet (`bin/servir-tailnet`) · falta que Freddy la abra en el teléfono/Quest y la use una semana (criterio 1) |
| [5 · Adaptador `grafo` y corte](FASE_5_ADAPTADOR_GRAFO_Y_CORTE.md) | F2 | `tablero.kind: grafo`, Todoist apagado | método (`bin/adapters/grafo/`) | 🟡 2/3 · adaptador (31 casos, 9 etapas probadas contra la API) + importador de `FASE_*.md`/§ABIERTO · Understand hecho · plan del corte escrito; el corte y C10 son de Freddy |
| [6 · VR solo lectura](FASE_6_VR_SOLO_LECTURA.md) | F1.3 | el mapa real en el visor: otra vista del mismo dato | `grafo-tareas.vr` | ✅ 3/3 · API, posiciones guardadas, bloqueo de la API · falta medir FPS en el visor |
| [7 · Editar desde el visor](FASE_7_EDITAR_DESDE_VR.md) | F3 | conectar y cerrar dentro del 3D | `grafo-tareas.vr` | ✅ 3/3 · conectar con el rayo, cerrar y ver qué libera, Zustand · falta medir FPS en el visor |
| [8 · Roles](FASE_8_ROLES.md) | C11 | un tablero por tipo de trabajo, y las FASE junto a las tarjetas | `api` + `web` + `roles.yaml` | ✅ 3/3 · `2dd7dad` api · `d3113ff` web · tablero por rol, FASE en solo lectura |
| [9 · Complementos](FASE_9_COMPLEMENTOS.md) | C11 | dudas con escalera, decisiones y «para decir» colgados del PBI | `api` + `web` + `roles.yaml`/`refs.yaml` | ✅ 3/3 · `c69086c` api · `ec572f9` web · escalar, decidir, rituales |
| [10 · El día](FASE_10_EL_DIA.md) | C11 | el parte para Fabián, lo que está en curso y los trámites de cierre, leídos del grafo | `api` + `web` + `roles.yaml` | ✅ 4/4 · `1ea1e2a` api · `d608901` web · parte para copiar, aviso de más de 2 en curso, trámites de cierre |
| [11 · Un tablero que se entiende](FASE_11_TABLERO_QUE_SE_ENTIENDE.md) | feedback | que cada columna y cada tarjeta se entiendan; las FASE como en fases.html | `api` + `web` + `roles.yaml` | ✅ 4/4 · `8ae618c` api · `f967329` web · FASE como fases.html, columnas explicadas, página de 8.300 → 971 px |
| [12 · Despliegue en el Mac Mini](FASE_12_DESPLIEGUE_MAC_MINI.md) | F1.1 c4 | el corte (FASE 5 t2): API, base y PWA siempre encendidas, solo por el tailnet | `api` + `web` + `deploy/` | 🟡 4/5 · desplegado e idempotente, datos migrados (214 · 137), respaldo diario probado; Freddy: teléfono y Uptime Kuma |
| [13 · El árbol HU → pieza → task](FASE_13_EL_ARBOL_HU_PIEZA_TASK.md) | C12 | que la VR muestre la red real (hoy 48 de 85 abiertas sueltas) | `api` (importadores) + `vr` | ✅ 4/4 · sueltas 48 → 35, racimo por HU en la VR; falta mirarlo en el visor |

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
