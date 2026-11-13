# FASE 23: LO QUE ENTRA AL GRAFO TAMBIÉN SALE

**Destraba**: que «El día» diga la verdad («Terminé» con lo mergeado, «Para decir» solo con lo que falta decir) y que el
tablero no se llene de lo ya hecho. Va antes que la FASE 18 y la 22: sin salida, lo que esas ordenen se vuelve a llenar.
**Estado**: sin rama
**Azure**: no aplica (tracker: none)
**Tipo**: devex
**Dependencias**: ninguna (toma la tarjeta `0cb90d00`, «el tablero se mueve solo al tildar», del 23-10)
**Fuente**: Freddy, 29-10, antes de la daily: «¿tenemos bien estructuradas las dudas y los problemas?… El día no está bien»
y «detectá mi método… dónde está el problema que no está considerado». Re-análisis de la sesión de control del Laboratorio,
plan aprobado el 29-10.

## El hueco, medido

Producción, 29-10: 299 nodos, 140 abiertos y 159 cerrados. Cada clase tiene entrada; varias no tienen salida.

| clase | abiertos / cerrados | salida |
|---|---|---|
| duda | 3 / 13 | sí: se cierra con la respuesta |
| trámite | 10 / 33 | sí: `traducir-fases.ts` `tramiteDe` la cierra con el cierre completo (el import es manual: atrasa) |
| «para decir» | 10 / 7 | **no**: nadie lo marca dicho; hay ítems del 18 al 27-10 ya dichos |
| propuesta | 28 / 1 | **no**: 15 vienen de la migración de Todoist del 17-10 y nunca se revisaron |
| tarjeta `[<task>]` (`board`) | 11 abiertas, 8 en APROBADO | **no**: ningún paso la cierra |
| tarea sin etiqueta | 16 | **no**: «Nueva tarea…» de la web y la migración, sin clasificar; mezcla trabajo y lo personal |
| duplicados | 2 | crear no busca: dos sesiones anotaron el mismo build del BFF con diagnósticos distintos |

**El contrato roto.** «Terminé» = TAREA/FASE con estado CERRADO desde `desde` (FASE 10; `derivado.repository.ts`
`terminadas`). La FASE 19 y el hook `fase-tilde` llevan la tarjeta a la **etapa** APROBADO con Mergeado, pero el **estado**
queda ABIERTO. La FASE se cierra sola solo con todas sus casillas tildadas (`traducir-fases.ts:94`, `fase.terminada`); la
tarjeta `[<task>]`, nunca. Resultado: el 28-10 se mergearon la 26958 y la 26960, y «Terminé» dice 0.

## Las decisiones

### D1 · La tarjeta `[<task>]` se cierra con su FASE — control, 29-10 `[código]`

Misma regla que el nodo FASE (`fase.terminada`): cuando el importador cierra la FASE, cierra la tarjeta de su task. La
etapa APROBADO sigue significando «Mergeado»; CERRADO, «ya no hay nada que hacer».

### D2 · «Para decir» se cierra al decirlo — control, 29-10 `[código]`

Un botón «dicho» en `/dia`: estado CERRADO y motivo «dicho en la daily dd-mm», que queda en la bitácora (`GET /cambios`).
`/flow:daily` sigue sin escribir en el parte; al final ofrece cerrar lo dicho, uno por uno, con el OK de Freddy.

### D3 · La propuesta tiene tres salidas, sin estado nuevo — control, 29-10 `[código]`

Se cierra con motivo `aceptada → <task o FASE>` o `rechazada`; o pasa a `complemento:espera` con qué espera y hasta cuándo.
Decidir si una idea vive es de Freddy: ningún comando la cierra solo.

### D4 · Una revisión semanal, no un comando — control, 29-10 `[negocio]`

Viernes, 15 minutos: «Sin columna», propuestas y lo sin etiqueta. Se clasifica o se descarta (el descarte de la FASE 16 se
deshace); nunca se borra. Es un ritual en `refs.yaml` `rituales` del Laboratorio.

### D5 · Crear busca antes — control, 29-10 `[código]`

`bin/adapters/grafo/pendiente` busca con `gr_listar` por las palabras del título; si hay uno abierto parecido, lo imprime
y no crea.

## Abierto

- ¿«Terminada» es demasiado estricta para cerrar la tarjeta? Una FASE con Mergeado y solo «Wiki» pendiente: hoy es
  trámite, la tarjeta seguiría abierta. Propuesta: alcanza con que el trámite esté cerrado.
- ¿El botón «dicho» va también en la VR?

## Understand

- [ ] Entendimiento — Freddy confirma D1-D5 y lo Abierto

## Tareas

### Construir
- [ ] **Tarea 1** · `importadores/fases/traducir-fases.ts` (+ spec, rojo primero): la tarjeta `[<task>]` de una FASE cerrada
  queda CERRADA (D1)
- [ ] **Tarea 2** · `grafo-tareas.web/app/dia/`: el botón «dicho» (D2), con e2e
- [ ] **Tarea 3** · `~/.claude/commands/flow/daily.md`: el paso final que ofrece cerrar lo dicho (D2)
- [ ] **Tarea 4** · `Laboratorio/bin/adapters/grafo/pendiente`: buscar antes de crear (D5), con su caso en `bin/tests/test_tablero.sh`
- [ ] **Tarea 5** · el ritual `revision-semanal` en `refs.yaml` del Laboratorio (D4)
- [ ] **Tarea 6** · el import al tildar, de la tarjeta `0cb90d00` (el hook `fase-tilde` corre el import de esa FASE)

### Probar con el equipo
- [ ] **Tarea 7** · una semana de uso: repetir el conteo de «El hueco, medido» y comparar

## Criterios de Aceptación

- [ ] 1 · una FASE con todo tildado deja su tarjeta CERRADA y aparece en «Terminé»; con Wiki sin tildar, sigue abierta
- [ ] 2 · «dicho» saca el ítem de «Para decir» y lo deja en la bitácora
- [ ] 3 · `pendiente` con un título casi igual a uno abierto no crea y muestra el existente
- [ ] 4 · a la semana, «para decir» abiertos ≤ los de esa semana y las propuestas sin salida bajan

## Fuera de alcance

- Normalizar etiquetas y destinatarios: FASE 18.
- Separar trabajo de lo personal: FASE 22.

## QA

- [ ] Listo para PR
- [ ] Mergeado
- [ ] Adoptado

## Cierre oficial en Azure

- [x] URL commit — no aplica (tracker: none)
- [x] Evidencias — no aplica (tracker: none)
- [x] Wiki actualizada — no aplica (tracker: none)
