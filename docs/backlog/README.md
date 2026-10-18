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
| [5 · Adaptador `grafo` y corte](FASE_5_ADAPTADOR_GRAFO_Y_CORTE.md) | F2 | `tablero.kind: grafo`, Todoist apagado | método (`bin/adapters/grafo/`) | 🟡 2/3 · adaptador (37 casos, 9 etapas probadas contra la API; ensayo del corte 2026-10-18 en la FASE 19) + importador de `FASE_*.md`/§ABIERTO · Understand hecho · plan del corte escrito; el corte y C10 son de Freddy |
| [6 · VR solo lectura](FASE_6_VR_SOLO_LECTURA.md) | F1.3 | el mapa real en el visor: otra vista del mismo dato | `grafo-tareas.vr` | ✅ 3/3 · API, posiciones guardadas, bloqueo de la API · falta medir FPS en el visor |
| [7 · Editar desde el visor](FASE_7_EDITAR_DESDE_VR.md) | F3 | conectar y cerrar dentro del 3D | `grafo-tareas.vr` | ✅ 3/3 · conectar con el rayo, cerrar y ver qué libera, Zustand · falta medir FPS en el visor |
| [8 · Roles](FASE_8_ROLES.md) | C11 | un tablero por tipo de trabajo, y las FASE junto a las tarjetas | `api` + `web` + `roles.yaml` | ✅ 3/3 · `2dd7dad` api · `d3113ff` web · tablero por rol, FASE en solo lectura |
| [9 · Complementos](FASE_9_COMPLEMENTOS.md) | C11 | dudas con escalera, decisiones y «para decir» colgados del PBI | `api` + `web` + `roles.yaml`/`refs.yaml` | ✅ 3/3 · `c69086c` api · `ec572f9` web · escalar, decidir, rituales |
| [10 · El día](FASE_10_EL_DIA.md) | C11 | el parte para Fabián, lo que está en curso y los trámites de cierre, leídos del grafo | `api` + `web` + `roles.yaml` | ✅ 4/4 · `1ea1e2a` api · `d608901` web · parte para copiar, aviso de más de 2 en curso, trámites de cierre |
| [11 · Un tablero que se entiende](FASE_11_TABLERO_QUE_SE_ENTIENDE.md) | feedback | que cada columna y cada tarjeta se entiendan; las FASE como en fases.html | `api` + `web` + `roles.yaml` | ✅ 4/4 · `8ae618c` api · `f967329` web · FASE como fases.html, columnas explicadas, página de 8.300 → 971 px |
| [12 · Despliegue en el Mac Mini](FASE_12_DESPLIEGUE_MAC_MINI.md) | F1.1 c4 | el corte (FASE 5 t2): API, base y PWA siempre encendidas, solo por el tailnet | `api` + `web` + `deploy/` | 🟡 4/5 · desplegado e idempotente, datos migrados (214 · 137), respaldo diario probado; Freddy: teléfono y Uptime Kuma |
| [13 · El árbol HU → pieza → task](FASE_13_EL_ARBOL_HU_PIEZA_TASK.md) | C12 | que la VR muestre la red real (hoy 48 de 85 abiertas sueltas) | `api` (importadores) + `vr` | ✅ 4/4 · sueltas 48 → 35, racimo por HU en la VR; falta mirarlo en el visor |
| [14 · Moverse y leer en el visor](FASE_14_MOVERSE_Y_LEER_EN_EL_VISOR.md) | FASE 13 | que Freddy recorra y lea el grafo en el Quest | `vr` | ✅ 3/3 · joysticks y etiquetas de frente, probado por Freddy en el visor; propuestas sin construir |
| [15 · La pantalla curva y las páginas](FASE_15_PANTALLA_CURVA_Y_LIBROS.md) | FASE 14 | leer el trabajo sin que se vea apilado: una HU a la vez | `api` + `vr` | 🟡 9/10 · curva, textos, páginas, gesto, más texto, familia, «Sin HU», fecha, mergeado (FASE 17), trámites marcados (dedo 3); falta la calibración 2 del gesto |
| [16 · Pulir en el grafo sin tocar Todoist](FASE_16_PULIR_EN_EL_GRAFO.md) | FASE 15 | limpiar en el grafo sin perder nada, camino al corte | `api` + `bin` | 🟡 3/4 · descartar (archivado, se deshace), bitácora, importador que respeta; falta el reporte final |
| [17 · Las dos caras de cada HU](FASE_17_LAS_DOS_CARAS_DE_CADA_HU.md) | FASE 15 | ver el plan (Draft trabajo) aparte de lo real, una HU a la vez | `api` + `vr` + `bin` | 🟡 6/8 · en producción (api `05d7887` `473897e` `0dbfbb9` `ff8bac1` · web `a20670e`): dos caras, mergeado tildado a mano, filtros 2 y 3 con los dedos, «Mover a» en la web (Trabajo \| Plan + clic derecho), Draft de la 20379 reconciliado, 0 dudas de FASE abiertas; falta calibrar los gestos con `?depurar` |
| [18 · Normalizar las tarjetas](FASE_18_NORMALIZAR_LAS_TARJETAS.md) | FASE 17 | los filtros por personas y entender qué es cada tarjeta suelta y para quién | `api` + `vr` + `web` | ⏳ 0/3 · propuesta (catálogo de complementos + persona conectada); espera el «sí» de Freddy |
| [19 · Probar el ciclo a mano](FASE_19_PROBAR_EL_CICLO_A_MANO.md) | FASE 17 | comprobar con una task real que cada paso del Laboratorio llega a la web y a la VR | `~/bin` (`fase-tildar`) + `bin/adapters/grafo` + `api` (`POST /piezas`) | 🟡 1/3 · guion escrito; ensayo del corte hecho y lo que encontró, arreglado con su prueba (`fase-tildar` mueve la tarjeta, adaptador con la API caída, `borrador` y `tarjeta`); faltan desplegar `POST /piezas` y la pasada de las 10 tarjetas `[FASE n]` en Todoist |

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
