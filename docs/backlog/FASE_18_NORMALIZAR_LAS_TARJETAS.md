# FASE 18: NORMALIZAR LAS TARJETAS (QUÉ ES CADA UNA Y PARA QUIÉN)

**Destraba**: los filtros 3 y 4 por personas («lo que espero de otros» / «lo que otros esperan de mí») y que Freddy entienda
de un vistazo qué es cada tarjeta suelta (una pregunta, un dolor, una propuesta, una nota) y a quién va, sin depender de cómo
la escribió ese día
**Listo para PR**: no · propuesta del agente, **espera el «sí» de Freddy** antes de tocar una sola tarjeta
**Prioridad**: Media — no frena el trabajo; ordena lo que el visor y la web ya muestran
**Dependencias**: FASE 9 (el catálogo de complementos), FASE 16 (pulir en el grafo con motivo, sin tocar Todoist)
**Fuente**: Freddy, 2026-10-18: «¿no podríamos normalizar sus etiquetas para que queden bajo una estructura más uniforme…
pregunta y destinatario… frontend, backend, analista…? Nunca fui tan consciente de normalizar sus etiquetas, ni sus datos, ni
su estructura… hay que analizarlo todo para hacer unas propuestas posibles, válidas e inteligentes»

## Lo medido (2026-10-18, producción, las 70 tarjetas abiertas de lo real: TAREA, DUDA y «para decir»)

- **19 no tienen ninguna etiqueta.**
- Las etiquetas que hay vienen de Todoist sin regla: `propuesta` 14, `board` 13 (la de las tarjetas de task), `retro` 6,
  `daily` 5, `supuesto` 2. Del catálogo del grafo (`complemento:<tipo>`) solo hay **17**: 16 trámites y 1 «para decir».
- **El catálogo ya existe y casi no se usa:** FASE 9 dejó 12 tipos en `docs/roles.yaml` —duda de negocio, duda de código,
  dolor, supuesto, decisión, para decir, propuesta, trámite, apunte, evidencia, trabajo de otro, captura—, con su escalera.
- Lo que dicen los títulos: 26 llevan fecha «dd-mmm ·», 26 nombran una FASE, 12 llevan `[id]` de task, 7 son preguntas
  («❓», «¿…?»), 6 «retro:», 4 «propuesta:», 3 «dolor:», 3 «para <persona>».

## La propuesta (para aprobar)

Dos ejes, con lo que el grafo ya tiene; nada nuevo en la API.

1. **Qué es (el tipo)** = el catálogo que ya existe, como etiqueta `complemento:<tipo>`. Regla para clasificar cada tarjeta:
   - etiqueta `propuesta` o título «propuesta:» → **propuesta**
   - etiqueta `retro` o título «retro:» → **para decir** en la retro
   - etiqueta `supuesto` → **supuesto**
   - título «dolor:» → **dolor**
   - una pregunta («❓», «¿…?») → **duda de negocio** o **duda de código**, según a quién va (el eje 2)
   - «para <persona>» sin pregunta → **para decir**
   - una corrección sin prioridad que no rompe nada (el tipo de muestra) → **propuesta**, colgada de la rama
     **🧹 Normalización** (ya creada el 2026-10-18)
   - lo que no encaja en nada → **captura** (Freddy decide después)
2. **Para quién (el destinatario)** — la idea de Freddy, en tres áreas: **negocio** (Persona A, Persona D) · **back**
   (Persona B) · **front** (Persona C, Persona E), más **Persona F** para lo de proceso. Se guarda como **conexión a la
   PERSONA** (`ESPERA_RESPUESTA_DE`), que el grafo ya tiene y la VR ya dibuja; el área sale de la persona, no se escribe dos
   veces. Esto es lo que alimenta los filtros 3 y 4.
3. **La HU no es una etiqueta:** si se sabe de qué HU es, la tarjeta cuelga de ella (`PERTENECE_A`); si no hay PBI, queda en
   «Sin HU». No se inventa un número.

**Cómo se aplica:** en el grafo, nunca en Todoist (FASE 16): el agente arma la clasificación de las 70 en una lista por
tarjeta, Freddy la aprueba en bloque (o tacha las que no), y se aplica con `PATCH` de etiquetas y conexiones con motivo —
queda en la bitácora y el importador lo respeta.

## Decisiones del agente (para revisar al leer)

1. **El catálogo de la FASE 9, no uno nuevo.** Ya tiene escalera, roles.yaml y lo lee la API; inventar otro duplicaría.
2. **El destinatario es una persona conectada, no una etiqueta `para:back`.** Una etiqueta se desincroniza cuando la duda
   escala (Persona A → Persona B); la conexión la mueve `POST /nodos/:id/escalar`, que ya existe.
3. **La fecha del título se deja.** Es como Freddy busca en Todoist; el grafo ya tiene `fechaOrigen` para ordenar.

## Understand

- [x] Entendimiento — 2026-10-18: pedido de Freddy y lo medido (arriba)

## Tareas

### Tarea 1: la lista de clasificación (solo lectura)
- [ ] Las 70 tarjetas con su tipo y su destinatario propuestos, y por qué (qué regla la clasificó); las que no encajan, aparte

### Tarea 2: aplicar lo aprobado
- [ ] `PATCH` de etiquetas y conexiones a la persona, con motivo; reimportar TRABAJO en seco: 0 pisadas

### Tarea 3: los filtros 3 y 4 en la VR y en la web
- [ ] «Lo que espero de otros» y «lo que otros esperan de mí», calculados en la API sobre esas conexiones

## Criterios de Aceptación

- [ ] 1 · Toda tarjeta abierta de lo real tiene un tipo del catálogo
- [ ] 2 · Toda pregunta abierta tiene a quién va (una PERSONA conectada)
- [ ] 3 · Una reimportación de TRABAJO no pisa nada de lo aplicado

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
