# FASE N: <QUÉ QUEDA RESUELTO, EN UNA LÍNEA>

<!-- Plantilla del rol «Seguridad» (Login por defecto, secretos fuera del repo, webhooks firmados, que nada se cobre o revierta dos veces). Sale de docs/roles.yaml: no editar la forma acá sin
     cambiarla allá. Copiar como docs/backlog/FASE_<N>_<NOMBRE>.md; toda casilla nace [ ]. -->

**Destraba**: <qué task, HU o persona queda libre al cerrar esta FASE>
**Estado**: <solo la rama entre backticks; el resto del estado vive en el grafo>
**Azure**: <task y PBI padre · o «no aplica (tracker: none)»>
**Tipo**: seguridad
**Dependencias**: <FASE o task que tiene que estar antes · o «ninguna»>
**Fuente**: <HU, wiki, reunión, reporte — de dónde sale cada requisito>

## El hueco, medido

Qué queda expuesto hoy y a quién, con evidencia reproducible. Nada de secretos reales en este archivo.

## Las decisiones

### D1 · <la decisión> — <quién, cuándo> `[código]` o `[negocio]`

## Abierto

<Dudas, dolores y supuestos sin cerrar. Cada uno va al tablero como complemento colgado de esta FASE, con su
origen (negocio o código) y su escalera de personas (refs.yaml). Al contestarse, pasa a «Las decisiones».>

## Understand

- [ ] Entendimiento

## Tareas

### Detectar
- [ ] **Tarea 1** · la evidencia del hueco: el request, el secreto o el flujo que hoy deja pasar lo que no debe

### Corregir
- [ ] **Tarea 2** · `<archivo:línea>` — el cambio (auth por defecto, secreto al gestor, firma, idempotencia)

### Verificar
- [ ] **Tarea 3** · el mismo ataque de Detectar, ahora rechazado; el caso rojo visto una vez

## Criterios de Aceptación

- [ ] 1 · <criterio verificable, que pueda fallar>

## Fuera de alcance

## QA

- [ ] Listo para PR
- [ ] Mergeado
- [ ] Mostrado al equipo

## Cierre oficial en Azure

- [ ] URL commit
- [ ] Evidencias
- [ ] Wiki actualizada
