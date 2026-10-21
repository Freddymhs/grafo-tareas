# FASE N: <QUÉ QUEDA RESUELTO, EN UNA LÍNEA>

<!-- Plantilla del rol «Calidad» (Refactor, Sonar, performance, logs, alertas y CI — sin cambiar contrato, con tests de rojo a verde). Sale de docs/roles.yaml: no editar la forma acá sin
     cambiarla allá. Copiar como docs/backlog/FASE_<N>_<NOMBRE>.md; toda casilla nace [ ]. -->

**Destraba**: <qué task, HU o persona queda libre al cerrar esta FASE>
**Estado**: <solo la rama entre backticks; el resto del estado vive en el grafo>
**Azure**: <task y PBI padre · o «no aplica (tracker: none)»>
**Tipo**: calidad
**Dependencias**: <FASE o task que tiene que estar antes · o «ninguna»>
**Fuente**: <HU, wiki, reunión, reporte — de dónde sale cada requisito>

## El hueco, medido

El reporte (Sonar, perf, logs) medido: cuántos casos, dónde, contra qué commit.

## Las decisiones

### D1 · <la decisión> — <quién, cuándo> `[código]` o `[negocio]`

## Abierto

<Dudas, dolores y supuestos sin cerrar. Cada uno va al tablero como complemento colgado de esta FASE, con su
origen (negocio o código) y su escalera de personas (refs.yaml). Al contestarse, pasa a «Las decisiones».>

## Understand

- [ ] Entendimiento

## Tareas

### Amarrar — línea base
- [ ] **Tarea 1** · medir el estado de hoy y dejar el test o el chequeo en rojo que prueba el problema

### Cambiar
- [ ] **Tarea 2** · `<archivo:línea>` — el cambio, sin tocar contrato ni comportamiento

### Red
- [ ] **Tarea 3** · el chequeo de la línea base, ahora en verde; el caso rojo visto una vez

## Criterios de Aceptación

- [ ] 1 · <criterio verificable, que pueda fallar>

## Fuera de alcance

## QA

- [x] Colección — no aplica: no cambia contrato
- [x] Auditoría — no aplica: no cambia contrato
- [ ] Listo para PR
- [ ] Mergeado

## Cierre oficial en Azure

- [ ] URL commit
- [ ] Evidencias
- [ ] Wiki actualizada
