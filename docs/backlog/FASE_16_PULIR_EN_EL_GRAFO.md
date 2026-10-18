# FASE 16: PULIR EN EL GRAFO SIN TOCAR TODOIST

**Destraba**: que Freddy limpie y ordene su trabajo en el grafo —lo que el visor le muestra que no encaja— sin miedo a perder nada y
sin tocar Todoist, hasta que el grafo sea un reflejo 1-1 pero pulido y se pueda desconectar Todoist (el corte de la FASE 5)
**Listo para PR**: no · aprobada por Freddy 2026-10-18 («dale, confío en ti»); api `e224433` desplegada (tareas 1-2); falta el reporte (4)
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

## Criterios de Aceptación

- [x] 1 · Descartar en el grafo sobrevive a una reimportación de Todoist (e2e)
- [x] 2 · Nada descartado se pierde: se puede ver (`GET /descartes`) y deshacer (restaurar, e2e)
- [ ] 3 · El reporte final cuenta todas las tarjetas de Todoist

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
