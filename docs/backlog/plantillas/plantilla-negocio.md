# FASE N: <QUÉ QUEDA RESUELTO, EN UNA LÍNEA>

<!-- Plantilla del rol «Negocio» (Detectar una necesidad, conversarla con el analista o el líder y redactar el PBI; el PBI aprobado pasa a Producto). Sale de docs/roles.yaml: no editar la forma acá sin
     cambiarla allá. Copiar como docs/backlog/FASE_<N>_<NOMBRE>.md; toda casilla nace [ ]. -->

**Destraba**: <qué task, HU o persona queda libre al cerrar esta FASE>
**Estado**: <solo la rama entre backticks; el resto del estado vive en el grafo>
**Azure**: <task y PBI padre · o «no aplica (tracker: none)»>
**Tipo**: negocio
**Dependencias**: <FASE o task que tiene que estar antes · o «ninguna»>
**Fuente**: <HU, wiki, reunión, reporte — de dónde sale cada requisito>

## El hueco, medido

La oportunidad o el dolor del negocio, con un dato que lo sostenga.

## Las decisiones

### D1 · <la decisión> — <quién, cuándo> `[código]` o `[negocio]`

## Abierto

<Dudas, dolores y supuestos sin cerrar. Cada uno va al tablero como complemento colgado de esta FASE, con su
origen (negocio o código) y su escalera de personas (refs.yaml). Al contestarse, pasa a «Las decisiones».>

## Understand

- [ ] Entendimiento

## Tareas

### Detectar
- [ ] **Tarea 1** · la necesidad, con la evidencia (quién la sufre, cuánto cuesta hoy)

### Conversar
- [ ] **Tarea 2** · con el analista funcional o el líder: qué se resolvió y qué quedó como duda

### Redactar
- [ ] **Tarea 3** · el PBI: objetivo, criterios numerados, fuera de alcance

## Criterios de Aceptación

- [ ] 1 · <criterio verificable, que pueda fallar>

## Fuera de alcance

## QA

- [ ] PBI aprobado

## Cierre oficial en Azure

- [x] URL commit — no aplica: no hay código
- [ ] Evidencias — el acta o el mensaje donde se aprobó
- [ ] PBI creado en el tracker — su número
