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
