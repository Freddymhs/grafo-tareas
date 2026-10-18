# FASE 16: PULIR EN EL GRAFO SIN TOCAR TODOIST

**Destraba**: que Freddy limpie y ordene su trabajo en el grafo —lo que el visor le muestra que no encaja— sin miedo a perder nada y
sin tocar Todoist, hasta que el grafo sea un reflejo 1-1 pero pulido y se pueda desconectar Todoist (el corte de la FASE 5)
**Listo para PR**: no · aprobada por Freddy 2026-10-18 («dale, confío en ti»); api `e224433` desplegada (tareas 1-2); reporte final escrito el 2026-10-18, antes del corte
**Prioridad**: Alta — es el camino al corte
**Dependencias**: FASE 15 (el visor que revela lo que no encaja), FASE 5 (el corte, pausado)
**Fuente**: Freddy, 2026-10-17: «podríamos borrarlo solamente a nivel de base de datos del proyecto de grafos, pero no del de Todoist,
porque sería muy peligroso… y al final revisar de a poco asegurándonos que es un reflejo 1-1 pero pulido y que no estamos perdiendo
nada valioso»

> **Por qué no basta con borrar en la base:** el importador de Todoist es idempotente por el id de cada tarjeta: lo borrado en el grafo
> vuelve en la siguiente importación. Y casi se borró algo valioso (la lista de cierres pendientes en Azure, 17 tasks) por un título
> que no decía qué era.

## La propuesta (para aprobar)

1. **Nunca se borra: se descarta.** Un nodo descartado guarda todo su contenido, el motivo y la fecha; la VR y la PWA no lo muestran.
2. **El importador lo respeta:** una tarjeta descartada que sigue en Todoist no se revive ni se pisa.
3. **Todoist no se toca.** Freddy lo sigue usando; lo nuevo sigue llegando al grafo.
4. **Al final, el reporte Todoist ↔ grafo:** cada tarjeta de Todoist como «igual», «descartada (motivo, fecha)» o «falta»; se revisa de a
   poco, y recién con todo cuadrado se desconecta Todoist.

## Understand

- [x] Entendimiento — 2026-10-17: pedido de Freddy (arriba); medido que el importador revive lo borrado (idempotente por `externo`)

## Tareas

### Tarea 1: descartar en la API
- [x] 2026-10-18, api `e224433`: `POST /nodos/:id/descartar {motivo}` **archiva** el nodo entero con sus conexiones (tabla
  `descartes`) y lo saca de `nodos`: así ninguna de las ~35 lecturas lo ve sin tocar ninguna (filtrar en cada una era frágil).
  `POST /descartes/:nodoId/restaurar` lo devuelve con su id, posición y conexiones. `GET /descartes`. Bitácora (tabla `cambios`):
  DESCARTE, RESTAURACION y EDICION — el `PATCH /nodos/:id` anota campo, antes, después y `motivo`. `GET /cambios`. e2e

### Tarea 2: el importador respeta lo pulido
- [x] 2026-10-18: no revive un descarte (omite sus conexiones y las cuenta) ni pisa un campo editado en el grafo. e2e: descartar +
  editar → reimportar → sigue descartado y la edición sigue (rojo probado quitando la regla). En producción, seco: 0 actualizados

### Tarea 3: descartar desde el visor
- [x] No aplica por ahora — 2026-10-17 Freddy: las acciones de la VR no las usa; descarta pidiéndolo en la conversación y el agente
  llama a la API con el motivo

### Tarea 4: el reporte Todoist ↔ grafo
- [x] 2026-10-18, desplegado con Freddy presente: `GET /contraste` (`calcularContraste`, puro) —
  de todo lo que vino de una fuente: `total` (el denominador), iguales, editados (qué campos, último motivo) y descartados (motivo);
  lo creado en el grafo no entra. Lo que falte en el grafo y siga en Todoist lo dicen los «nuevos» del importador en seco. Unit 3 +
  e2e; API 101 unit · 50 e2e. Primer descarte real: «preguntas» (sin contenido), a pedido de Freddy

## Preguntas para Freddy (abiertas)

Cerrada 2026-10-18: se construye así (Freddy: «dale»). Pendiente: el formato del reporte final (tarea 4).

## Revisión de «Sin HU» (2026-10-18, para decidir con Freddy)

46 tarjetas sueltas, todas con fecha (13-09 → 17-10): de TRABAJO, sin `[número]` de una task con FASE, sin conexiones. Opinión del
agente por grupo; **nada se descarta sin el «sí» de Freddy**.

1. **Propuestas y retros del 01-oct** (11, solo título): ideas para el equipo, no tareas → mejor un documento de propuestas.
2. **Archivadas el 06-10** (11, CERRADAS en «🔎 Precheck fin de sprint (archivadas)»): candidatas a descarte. Revisar aparte las 3
   con contenido propio: «¿La sinonimia se elige y se guarda?», «30-sep · api.notify (FASE_14)…», «bloqeante tomas» (2.000 caracteres).
3. **Dolores y dudas en espera** (4): valiosos; les falta su relación con la HU 20379 (hablan del listado de solicitudes).
4. **Pendientes concretos** (7): reales. Posibles hechos o repetidos: el diagrama a Fabián (14-sep) y «Agregar URL commit… 7 de
   Sonar», que se superpone con «Cierres pendientes en Azure».
5. **Capturas rápidas sin descripción** (8): notas de Freddy; solo él sabe si siguen.
6. **Dos supuestos del 28-09** («candidato, NO confirmado»): ver si se confirmaron.

Pregunta abierta: ¿descartar las 8 archivadas sin contenido propio del grupo 2 (motivo: «archivada el 06-10 por la sesión de control
como resuelta u obsoleta»)?

## Pasada sobre lo que el dedo 3 deja encendido (2026-10-18, pedido de Freddy desde el visor: «una pasada aunque sea»)

Medido en producción con la regla del filtro 3 (abierto, ni mergeado ni trámite): 19565 **25** · 20379 **4** · Sin HU **42**.
Candidatas, **ninguna se descarta sin su «sí» por número**:

1. 19565 · 6 dudas: 4 contestadas (A1, A2, nota de cierre, 24973) → cerrar en `entendimiento.md`; quedan Q4 y Q10.
2. 19565 · 6 notas del 01-oct colgadas de FASEs (retros y la propuesta del PDF; «Materia Seca» para Thomas, a confirmar) → notas, no tareas.
3. 19565 · 9 tarjetas `[FASE 22-30]` de Sonar en APROBADO/LISTO PARA PR/Pull Request/TESTEADO: FASE mergeada, Azure En revisión → el
   cierre que falta; se quedan (cierran solas con la URL commit).
4. 19565 · «[26317] Husky esencial · esperar el código de las reglas de Sonar»: la FASE 30 ya está mergeada → sospecha de obsoleta.
5. 19565 · reales: [FASE 37] 26610, «Sonar BFF Sin PR» (15-oct), «[correcciones viejas]».
6. 20379 · reales: 25325, aclaración Graciany (14-oct), comuna de feriados (15-oct); «03-oct para Thomas: seeder» → ¿hecha?
7. Sin HU · 11 del 01-oct (5 propuestas + 6 retros) → a un documento de propuestas, no tarjetas.
8. Sin HU · capturas sueltas (24-sep, 23-sep, 02-oct ×3, 16-oct «.md desactualizados», 17-oct «observación») → solo Freddy sabe.
9. Sin HU · probablemente hechas o vencidas: 14-sep diagrama a Fabián, 14-sep pruebas de carga, 13-sep tope CF, 14-oct horas extras,
   29-sep «selector de actividad no filtra por laboratorio» (= A1, contestada).
10. Sin HU · reales, se quedan: task tipo de muestra para Fabián (= Q4), 3 dolores del 07-oct, Calendarios X-Component, 25682, c1
    husky, [26469] identidad, husky extras ×2 (FASE 36), Carabantes registro de usuarios, falta data UO, 06-oct para Thomas 2 tests,
    [26750] Sonar api.solicitudes (nueva 18-10), los 2 supuestos del 28-sep.

- [x] 2026-10-18, Freddy: «no quiero leer… valídalas tú y si te parecen lógicas u obvias, toma las respuestas»; Sonar, husky y la
  26750 se quedan sí o sí. 37 candidatas verificadas por 3 agentes Sonnet de solo lectura (Fable agotado), con cita cada una; el
  orquestador recomprobó las citas antes de descartar. **20 descartadas** con su cita en el motivo: 12 propuestas/retros del 01-oct
  registradas en `Laboratorio/docs/onboarding/propuestas.md:26-29`; las 2 de UX del 02-oct (`:30-31`); el seeder para Thomas (`:32`);
  el pase al daily de los 2 tests rojos (`hallazgos.md:1018`); la duda A1 en sus dos tarjetas (Carabantes, Azure 24852 28-09 +
  reunión 29-09); Materia Seca (`:23`) y el PDF con parámetros (`:24`). **17 se quedan**: sin forma de verificar (SSO, horas extras,
  colección transversales, observación, diagrama a Fabián, historia para Graciany), vivas sin registro (etapa de IA en el pipeline,
  retro de la wiki en el PR, tope de Control Fronterizo = 50 sin confirmar, pruebas de carga, ingredientesActivos opcional vs §8.4,
  tipo de muestra, barrido de `.md`, falta data de UO, aviso N1/N2 a Tomás) y husky regex + [26317] por la excepción. Contraste:
  232 · 198 iguales · 7 editados · 27 descartados
- [x] 2026-10-18 (tarde), re-auditoría con Opus de los 20 descartes: **9 perdían información** y se **restauraron**
  (`POST /descartes/:id/restaurar`). El más grave: «el selector de Laboratorio Destino no filtra por Análisis Específico
  (§10.1)» se había cerrado con la respuesta de OTRA pregunta (la A1 es el selector de actividad; el hueco de §10.1 sigue sin
  registrar). Los otros 8: el PDF con parámetros (cita de Tomás y dónde va el cambio), 5 retros cuyo caso concreto no está en
  `propuestas.md:29` (la fila dice «cada uno con su caso» y no trae ninguno), la medición del 06-10 de los 2 tests rojos y el plazo
  de la norma de comentarios. Lección: «registrada en el doc X» no alcanza si el doc tiene el título y no el contenido.
  Quedan **11 descartados** hoy. Contraste: 236 · 211 iguales · 7 editados · 18 descartados

## Verificación de tarjetas «resueltas» que seguían abiertas (2026-10-18, pedido de Freddy)

Regla de Freddy: se cierran **solo con evidencia** (HU, código, reuniones); falsear una decisión de negocio o de código es lo peor.
3 candidatas de 93 abiertas (título que dice resuelta/contestada/descartada). Cada una la verificó un agente Fable de solo lectura
(docs, `origin/develop`, Azure por GET) y el orquestador recomprobó los datos clave antes de decidir.

1. **«15-oct · Para Thomas: preguntas de código»** → **cerrada** en el grafo: las 5 afirmaciones confirmadas (reunión 15-10, 403 en
   el bff PR 5182, comentario 7594339 de Carabantes, `recepcion:ver-muestra` en identidad, FASE_33 D4). Su descripción aún dice
   «Espera, no se manda todavía» para la 3: contradice al título.
2. **«RESUELTA por HU · NO preguntar a Carabantes»** → **cerrada**: la contestan la HU 24569 (estado New, sin aprobar) y la 18278
   (aprobada). Correcciones en el motivo: la 25818 cuelga de la 24568; `acceso_service.ts:109`; lo de QA está en `FASE_32:84`.
3. **«1.3 · Objetivo para las UO no agrícolas · descartada para el MVP»** → **cerrada** (el agente la había dejado como riesgo; al
   revisarla de nuevo no afectaba nada). La wiki de la HU 20379 define el Objetivo como columna dinámica por Unidad («Agrícola:
   Actividad») y Thomas lo confirmó el 02-10 (`hallazgos.md:1049`); la 25312 está Done con `nombreActividad`; la única HU que crea
   solicitudes es la 19565 (Agrícolas y Forestales). Freddy, 18-10: el alcance es solo Agrícola por ahora.

## Reporte final Todoist ↔ grafo (2026-10-18, antes del corte de la FASE 5)

La foto del «antes». Respaldo `grafo-2026-10-18_2037.dump` y `GET /contraste` contra producción, más las importaciones en seco
(lo que falta en el grafo y sigue en Todoist):

- **Contraste** de todo lo que vino de Todoist: **223**. **186 iguales** · **19 editados en el grafo**, que se conservan (11
  etiquetas, 4 títulos, 4 estados) · **18 descartados**, que no reviven.
- **Faltantes:** TRABAJO, 135 tarjetas activas leídas: **0 nuevas, 0 por actualizar, 0 vínculos nuevos**. Draft, 10 leídas: **0 /
  0 / 0**. FASE del Laboratorio: 0 nuevas, 0 por actualizar.
- **Vínculos chuecos y tarjetas volando**, medidos el mismo día (FASE 19): 0 de 125 vínculos y 0 de 72 tarjetas abiertas.
- **Lo creado solo en el grafo** no entra al contraste, y ningún importador lo toca: 20 nodos (dudas, la propuesta para Thomas,
  Tomás Soto…) y sus vínculos.

Conclusión: el grafo es un reflejo 1-1 de Todoist, pero pulido. Cada diferencia tiene su motivo:

| estado | campos | tarjeta | motivo |
|---|---|---|---|
| descartado | — | 01-oct · Thomas: corregir las 6 filas de Materia Seca REQUERIDO en la … | Registrada en Laboratorio/docs/onboarding/propuestas.md:23 (Materia Seca REQUERIDO, a Thomas) y FASE_15 N2. Si… |
| descartado | — | 01-oct · propuesta: retro automática del sprint por encima del flujo (… | Registrada en Laboratorio/docs/onboarding/propuestas.md:28 (retro automática del sprint). La tarjeta duplicaba… |
| descartado | — | 01-oct · propuesta: wiki casi automática — carpeta propia en un repo d… | Registrada en Laboratorio/docs/onboarding/propuestas.md:27 (wiki casi automática, a Fabián). La tarjeta duplic… |
| descartado | — | 01-oct · retro: pipeline que falle con test rojo — consulta_solicitude… | Registrada en Laboratorio/docs/onboarding/propuestas.md:29 (uno de los 9 temas de la retro del 05-10). La tarj… |
| descartado | — | 01-oct · retro: test con datos de catálogo reales, no fabricados — la … | Registrada en Laboratorio/docs/onboarding/propuestas.md:29 (uno de los 9 temas de la retro del 05-10). La tarj… |
| descartado | — | 01-oct · retro: test de contrato BFF↔microservicio — dos veces un camp… | Registrada en Laboratorio/docs/onboarding/propuestas.md:29 (uno de los 9 temas de la retro del 05-10). La tarj… |
| descartado | — | 01-oct · retro: toda decisión de negocio va como comentario al PBI en … | Registrada en Laboratorio/docs/onboarding/propuestas.md:29 (uno de los 9 temas de la retro del 05-10). La tarj… |
| descartado | — | 02-oct · cambios qe tiene ----   . mejor qe digan TBD o algo similar y… | Registrada en Laboratorio/docs/onboarding/propuestas.md:30 (propuesta de UX del 02-10, a Diseño). La tarjeta d… |
| descartado | — | 02-oct · deberiamos tener un simbolo o algo qe indique el LOADING de u… | Registrada en Laboratorio/docs/onboarding/propuestas.md:31 (símbolo de LOADING, a Diseño). La tarjeta duplicab… |
| descartado | — | 03-oct · para Thomas: que desarrollo_seeder reparta las solicitudes de… | Registrada en Laboratorio/docs/onboarding/propuestas.md:32 (seeder con todos los estados, a Thomas). Sigue sin… |
| descartado | — | 29-sep · el selector de actividad del Paso 2 no filtra por el laborato… | Registrada en Laboratorio/docs/hallazgos.md:539 (el selector del Paso 2 no esconde actividades; no crítico, re… |
| descartado | — | [25327] FASE 33 · PR 5207 + 5208 mergeados · falta URL commit (Evidenc… | Duplica el trámite automático de la FASE 33 («FASE 33: falta …»): lo que falta para cerrar se lee de la FASE (… |
| descartado | — | [25476] FASE 32 · PR 5182 mergeado · falta URL commit y Evidencias (cr… | Duplica el trámite automático de la FASE 32 («FASE 32: falta …»): lo que falta para cerrar se lee de la FASE (… |
| descartado | — | [25699] FASE 34 · PR 5205 + 5204 mergeados · falta URL commit, Evidenc… | Duplica el trámite automático de la FASE 34 («FASE 34: falta …»): lo que falta para cerrar se lee de la FASE (… |
| descartado | — | [25936] FASE 22 · PR 5090 → Done · falta URL commit y Evidencias | Duplica el trámite automático de la FASE 22 («FASE 22: falta …»): lo que falta para cerrar se lee de la FASE (… |
| descartado | — | [25937] FASE 35 · PR 5198 mergeado · falta URL commit y Evidencias | Duplica el trámite automático de la FASE 35 («FASE 35: falta …»): lo que falta para cerrar se lee de la FASE (… |
| descartado | — | preguntas | sin contenido: una sesión la archivó sin decir qué preguntas eran |
| descartado | — | 🟡 | 🟡 no es una rama: es la marca de estado «en curso» de los docs del Laboratorio, puesta tras el número en 3 tar… |
| editado | estado | 15-oct · Para Thomas: preguntas de código (25476 y 25327) · 1 y 2 CONT… | Verificada 18-10 (solo lectura): 1 y 2 en docs/reuniones/reunion-2026-10-15-thomas-unidades.md:19-43; 403 en e… |
| editado | estado | 3️⃣ 20379 · 1.3 · Objetivo para las UO no agrícolas · descartada para … | Fuera del alcance actual (Freddy, 18-10: por ahora solo Agrícola; Pecuaria, Semillas y Enológico no existen ni… |
| editado | estado | 3️⃣ 20379 · 4.1b · Proceso nocturno que manda el aviso · por crear | Cerrada en el Draft de Todoist el 2026-10-18 (reparto de la 20379): la cubre la task 26311 de tsoto (proceso n… |
| editado | estado | RESUELTA por HU · NO preguntar a Carabantes: quién asigna la Unidad Or… | Verificada 18-10 (solo lectura): quién asigna la UO lo contestan HU 24569 (Admin Central o de UO; estado New, … |
| editado | etiquetas | [26750] Sonar api.solicitudes · 101 issues (29 critical, 72 major) | Task 26750 (Sonar api.solicitudes): hija de la HU 19565 en Azure (GET 2026-10-18) y de calidad como las demás … |
| editado | etiquetas | [FASE 22] refactor(#25936): campos inyectados como readonly en el códi… | es la tarjeta de la FASE 22, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 23] refactor(#26307): el BFF lee los errores de los microservici… | es la tarjeta de la FASE 23, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 24] refactor(#26310): el nivel del log de acceso sale de una fun… | es la tarjeta de la FASE 24, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 25] refactor(#26312): 12 detalles de forma del reporte Sonar en … | es la tarjeta de la FASE 25, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 26] refactor(#26313): el parser de /optionsFilter del usuario co… | es la tarjeta de la FASE 26, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 27] refactor(#26315): los parsers de /options y /optionsFilter e… | es la tarjeta de la FASE 27, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 28] refactor(#25935): los selectores del usuario deciden su carg… | es la tarjeta de la FASE 28, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 29] refactor(#26316): getLoginUrl con una sola salida y el guard… | es la tarjeta de la FASE 29, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 30] chore(#26317): husky con typecheck y las reglas de Sonar en … | es la tarjeta de la FASE 30, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | etiquetas | [FASE 37] refactor(#26610): upload, handleErrors y los arranques de bi… | es la tarjeta de la FASE 37, de Tipo calidad: va al tablero de Calidad (FASE 19) |
| editado | titulo | 🔵 Unidades organizacionales | El nombre de la rama, de la descripción de la sección ENTENDIMIENTO de TRABAJO (Freddy, 2026-10-18): sin él la… |
| editado | titulo | 🟠 Feriados | El nombre de la rama, de la descripción de la sección ENTENDIMIENTO de TRABAJO (Freddy, 2026-10-18): sin él la… |
| editado | titulo | 🟢 Recepción | El nombre de la rama, de la descripción de la sección ENTENDIMIENTO de TRABAJO (Freddy, 2026-10-18): sin él la… |
| editado | titulo | 🟣 Sonar | El nombre de la rama, de la descripción de la sección ENTENDIMIENTO de TRABAJO (Freddy, 2026-10-18): sin él la… |

## Criterios de Aceptación

- [x] 1 · Descartar en el grafo sobrevive a una reimportación de Todoist (e2e)
- [x] 2 · Nada descartado se pierde: se puede ver (`GET /descartes`) y deshacer (restaurar, e2e)
- [x] 3 · El reporte final cuenta todas las tarjetas de Todoist — 2026-10-18: 223 contrastadas y 0 faltantes (§ Reporte final)

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
