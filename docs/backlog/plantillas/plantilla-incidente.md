# FASE N: <QUÉ QUEDA RESUELTO, EN UNA LÍNEA>

<!-- Plantilla del rol «Incidente» (Un bug en producción — reproducir, arreglar, verificar y explicar qué lo causó). Sale de docs/roles.yaml: no editar la forma acá sin
     cambiarla allá. Copiar como docs/backlog/FASE_<N>_<NOMBRE>.md; toda casilla nace [ ]. -->

**Destraba**: <qué task, HU o persona queda libre al cerrar esta FASE>
**Estado**: <solo la rama entre backticks; el resto del estado vive en el grafo>
**Azure**: <task y PBI padre · o «no aplica (tracker: none)»>
**Tipo**: incidente
**Dependencias**: <FASE o task que tiene que estar antes · o «ninguna»>
**Fuente**: <HU, wiki, reunión, reporte — de dónde sale cada requisito>

## El hueco, medido

Qué se rompió, desde cuándo, a quién afecta y cómo se detectó.

## Las decisiones

### D1 · <la decisión> — <quién, cuándo> `[código]` o `[negocio]`

## Abierto

<Dudas, dolores y supuestos sin cerrar. Cada uno va al tablero como complemento colgado de esta FASE, con su
origen (negocio o código) y su escalera de personas (refs.yaml). Al contestarse, pasa a «Las decisiones».>

## Understand

- [ ] Entendimiento

## Tareas

### Reproducir
- [ ] **Tarea 1** · el caso que falla en producción, reproducido en local o en un test

### Arreglar
- [ ] **Tarea 2** · `<archivo:línea>` — la causa, no el síntoma

### Verificar
- [ ] **Tarea 3** · el caso de Reproducir, ahora en verde, y que no rompió lo vecino

## Criterios de Aceptación

- [ ] 1 · <criterio verificable, que pueda fallar>

## Fuera de alcance

## QA

- [ ] Listo para PR
- [ ] Mergeado
- [ ] Desplegado
- [ ] Explicado

## Cierre oficial en Azure

- [ ] URL commit
- [ ] Evidencias
- [ ] Wiki actualizada
