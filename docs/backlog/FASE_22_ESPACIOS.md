# FASE 22: ESPACIOS: EL GRAFO PARA MÁS QUE EL TRABAJO

**Destraba**: usar el mismo grafo para el trabajo, los proyectos personales y lo que venga (hobby, estudio), sin
mezclarlos en una sola vista y sin romper los comandos que hoy lo usan para el trabajo.
**Estado**: sin rama
**Azure**: no aplica (tracker: none)
**Tipo**: producto
**Dependencias**: ninguna
**Fuente**: Freddy, 24-10: «Grafos actualmente está relacionado exclusivamente al trabajo. ¿No podía colocarle un padre
para que sea como trabajo, otro como proyectos personales, y otro… otra cosa?»

## El hueco, medido

Medido el 24-10, leyendo `grafo-tareas.api/prisma/schema.prisma` y `refs.yaml`:
- **Los nodos ya son genéricos.** `TipoNodo` (TAREA, HISTORIA, FASE, RAMA, DUDA, PERSONA, PR, DAILY_ITEM) no dice
  «trabajo» en ningún lado; `externoOrigen` es texto libre.
- **Lo que lo ata al trabajo es que todo vive en un solo grafo.** No hay ningún campo que separe un nodo del trabajo de
  uno personal: la web, la VR y el parte del día muestran todo junto.
- **La configuración del área es una sola.** El módulo `area` lee las escaleras de dudas y los rituales de un único
  `refs.yaml`.

## Las decisiones (propuestas, sin confirmar)

### D1 · Un campo `espacio` en cada nodo, no un nodo padre — propuesta 24-10 `[código]`

- **Qué:** `Nodo.espacio` (texto, con índice). Los valores válidos viven en la configuración (una lista con nombre y
  color por espacio), no en el código.
- **Por qué un campo:** filtrar por un campo es directo y se indexa. Con un nodo ESPACIO del que cuelga todo por
  `PERTENECE_A` habría que recorrer el grafo en cada consulta, y un nodo suelto quedaría sin espacio.
- **Lo que hay hoy:** migración con backfill a `trabajo` en un paso aparte (`CLAUDE.md` global §8), así que los comandos,
  el importador de FASE y el adaptador siguen igual.

### D2 · Todo filtra por espacio; sin elegir, se ve `trabajo` — propuesta 24-10 `[código]`

- **API:** `?espacio=` en las lecturas (nodos, tablero, «hoy puedo», bloqueado, páginas) y en las altas.
- **Web y VR:** un selector de espacio que se recuerda por dispositivo.
- **Conexiones:** una conexión entre espacios distintos ¿se permite o se rechaza? (ver Abierto).

### D3 · Cada espacio puede tener su configuración — propuesta 24-10 `[código]`

Las escaleras de dudas y los rituales del módulo `area` pasan a leerse por espacio. Si un espacio no declara nada, no
tiene rituales (no hereda los del trabajo).

## Abierto

- **Choca con una regla vigente:** `CLAUDE.md` §Trampas dice «El grafo de producción es el trabajo del SAG, nada más»
  (Freddy, 17-10: «tenemos dos mundos… eso está mal»). Esa regla nació de FASE de otro orquestador mezcladas sin ningún
  campo que las separara; esta FASE propone justamente ese campo. Si se confirma, la regla se reescribe en el mismo
  cambio («cada mundo es un espacio; nada se mezcla sin espacio»), no se deja al lado.
- ¿Qué espacios nacen además de `trabajo`? (propuesta: `personal`)
- ¿Una conexión puede cruzar espacios?
- ¿El importador de Todoist mapea un proyecto de Todoist a un espacio?

## Understand

- [ ] Entendimiento — confirmar D1-D3 y lo Abierto con Freddy antes de abrir la rama

## Tareas

### `grafo-tareas.api`
- [ ] **Tarea 1** · `prisma/schema.prisma` + migración: `espacio` con índice; backfill a `trabajo` en una migración aparte
- [ ] **Tarea 2** · la lista de espacios en la configuración y `?espacio=` en lecturas y altas (unitario y e2e rojos primero)
- [ ] **Tarea 3** · el módulo `area` por espacio

### `grafo-tareas.web`
- [ ] **Tarea 4** · el selector de espacio y el filtro en tablero, detalle y búsqueda

### `grafo-tareas.vr`
- [ ] **Tarea 5** · el mismo selector en la VR

### `bin`
- [ ] **Tarea 6** · el importador de FASE y el adaptador `grafo` escriben `espacio=trabajo` explícito

## Criterios de Aceptación

- [ ] 1 · tras la migración, todos los nodos de producción tienen `espacio = trabajo` y los comandos del Laboratorio
  funcionan igual (el ciclo de la FASE 19 pasa)
- [ ] 2 · un nodo creado en `personal` no aparece en el tablero, el parte ni «hoy puedo» de `trabajo`, y al revés
- [ ] 3 · un espacio nuevo se agrega editando la configuración, sin tocar código

## Fuera de alcance

- Usuarios distintos por espacio o permisos: el grafo sigue siendo de una persona.

## QA

- [ ] Colección — no aplica (proyecto personal, sin Postman)
- [ ] Auditoría
- [ ] Listo para PR
- [ ] Mergeado

## Cierre oficial en Azure

- [x] URL commit — no aplica (tracker: none)
- [x] Evidencias — no aplica (tracker: none)
- [x] Wiki actualizada — no aplica (tracker: none)
