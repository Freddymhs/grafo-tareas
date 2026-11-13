# Diseño: el grafo con espacios y proyectos (borrador, 2026-11-12)

Estado: **borrador sin aprobar.** Reemplaza la propuesta de `docs/backlog/FASE_22_ESPACIOS.md` (un campo `espacio` de texto
con la lista en configuración, sin nivel de proyecto), que Freddy amplió en la conversación del 2026-11-12.
Marcas: **[Freddy]** lo dijo él · **[mi decisión]** lo decidí yo y él puede revertirlo · **[abierto]** lo contesta él.

## 1. Para qué

El grafo nació para el trabajo en SIGSA (cliente SAG, Laboratorio), pero el concepto siempre fue más amplio: "trabajo y
proyectos (laborales, freelance, personales, de aprendizaje)" (`_CONCEPTO.md:11`). Freddy ya no trabaja en SIGSA y quiere
que el grafo sea su **memoria de trabajo de mediano y largo plazo**: personal, conectada, y hecha para **avanzar**, no
para archivar. **[Freddy]**

- Lo que se pierde hoy entre contextos: lo que no entró en el sprint, el script que creó y ya no recuerda cómo se usa,
  un pendiente con su mamá, una idea que todavía no armó. **[Freddy]**
- La diferencia con Obsidian / la bóveda: aquello guarda para recordar algún día; esto avanza día a día. **[Freddy]**
- El visor VR (Quest 3S) es para ver, intuir y abstraer relaciones que en una lista no aparecen. **[Freddy]**
- Lo que lo distingue además: la **cartografía de dispositivos**, recordar qué herramientas, atajos y comandos tiene
  cada máquina y cómo se usan; verlas despierta "podría crear o mejorar esto", y eso también es avance. **[Freddy]**

## 2. Objetivos

1. **Dos niveles sobre los nodos: Espacio → Proyecto.** **[Freddy]**
   - Espacio = quién te contrata o en qué contexto estás: SIGSA, Core (un empleo futuro), Freelance, Personal.
   - Proyecto = lo que hay dentro: SIGSA → SAG, SII; Freelance → trabajo 1, 2, 3; Personal → Familia, Mis máquinas.
   - Crece sin rediseño: un empleo con 1 proyecto hoy puede tener 4 mañana.
2. **Espacios y proyectos se crean desde la app**, no editando un archivo. **[Freddy]**
3. **La interfaz muestra el espacio como pestaña principal y los proyectos como sub-pestañas.** **[Freddy]**
   Variante A del boceto (pestañas arriba, sub-pestañas debajo). **[Freddy, 2026-11-13]**
4. **Nada de lo que existe se pierde**: todo el grafo actual pasa a SIGSA → SAG. **[mi decisión]**
5. **"Hoy puedo", tablero, día y páginas se filtran por proyecto o espacio**, y hay una vista de "todo". **[mi decisión]**
6. **La búsqueda (`?q=`) cruza todos los espacios por defecto**: el caso es "sé que existe pero no me acuerdo dónde". **[mi decisión]**

## 3. No objetivos

- Multiusuario, permisos por espacio o login. El grafo sigue siendo de una persona (`_CONCEPTO.md:16,39`).
- Sub-proyectos o un tercer nivel. La investigación de otros sistemas (Things: área → proyecto; Linear: workspace →
  proyecto) dice que dos niveles alcanzan, y que la estructura que se diseña de antemano mata el uso.
- Configuración por espacio de escaleras, rituales y personas (`area`, `refs.yaml`): hoy solo la usa SIGSA. Queda global
  en esta etapa.
- La cartografía automática y la captura desde el teléfono: son proyectos siguientes, ver §8.
- Salud: espera login y marca de sensible (§5b).

## 4. Anti-objetivos (fracasaría aunque funcione)

- **Que el grafo sea la décima lista de "mis proyectos" desincronizada** (hoy hay al menos 9: perfiles de Herdr,
  `~/bin/areas`, `matrix-gh`, `resume.json`, `projects.matrix`, cheatsheet, `pc-repos`, Todoist, `refs.yaml`). El
  espacio/proyecto del grafo **no** es un reflejo de `buildworkspace` ni de los entornos de Herdr: es otro alcance. **[Freddy]**
- Que haya que crear una sección para cada cosa de la vida. **[Freddy]**
- Que los comandos que hoy escriben en el grafo dejen de andar en silencio (caen en un proyecto equivocado sin avisar).

## 5. Modelo **[mi decisión, salvo lo marcado]**

- **Tabla `Espacio`**: id, nombre, color, orden, `archivado` (bool), createdAt.
  - Archivado = sale de las pestañas y de "hoy puedo", sigue en la búsqueda y en la vista "todo". SIGSA es el primer caso.
- **Tabla `Proyecto`**: id, espacioId, nombre, color, orden, `archivado`.
  - Cada espacio nace con un proyecto **"General"**: la bandeja para lo que todavía no tiene proyecto. Así `Nodo.proyectoId`
    es siempre obligatorio y no hace falta un segundo campo `espacioId` en el nodo.
- **`Nodo.proyectoId`** obligatorio, con índice. El espacio se deriva del proyecto.
- **Conexiones entre proyectos y entre espacios: permitidas.** Ejemplo de Freddy: un script de Mis máquinas que sirve en
  una tarea de SIGSA. `libera` y `bloqueado` siguen las conexiones sin importar el proyecto (un bloqueo es un bloqueo).
- **Personas**: un nodo PERSONA vive en el "General" de un espacio y se conecta desde cualquier proyecto.
- **`@@unique([externoOrigen, externoId])` queda global**: el origen ya identifica la fuente (por ejemplo `todoist:<id>`).
- **Todos los tipos de nodo viven en un proyecto**, incluidos los del método de trabajo (RAMA, FASE, DAILY_ITEM, PR). No se
  valida que una conexión una nodos del mismo proyecto: se permite todo. **[mi decisión]**
- **Vecinos de otro proyecto en una vista filtrada**: se muestran como nodos "fantasma" (atenuados, con el nombre de su
  proyecto) en el detalle del tablero y en la VR, y **cuentan** en `bloqueado` y `libera`. La consulta filtrada trae los
  nodos del proyecto más sus vecinos directos. **[mi decisión]**
- **Mover y borrar**: un nodo se mueve con `PATCH /nodos/:id { proyectoId }` (también en lote, para vaciar "General").
  Espacios y proyectos se **archivan**; borrar solo se permite si están vacíos. **[mi decisión]**
- **Lo archivado**: no aparece en "hoy puedo" ni en el tablero; sí en la búsqueda y en la vista "todo". Un `BLOQUEADA_POR`
  hacia un nodo archivado **sigue bloqueando** (un bloqueo es un hecho) y se ve como fantasma con la marca "archivado". **[mi decisión]**
- **Etapas por espacio**: las 14 etapas actuales (ENTENDIMIENTO… "Precheck fin de sprint") son del método de SIGSA y no
  tienen sentido en Familia. Cada espacio guarda **su** lista de etapas en la base (editable desde la app). Un espacio
  nuevo nace con tres: Pendiente, Haciendo, Hecho. SIGSA conserva las 14. Los rituales (daily, retro) y "el día" solo
  existen en los espacios que los declaran. Esto adelanta una parte de lo que §3 dejaba global. **[mi decisión]**
- **Nombres únicos**: `@@unique([espacioId, nombre])` en Proyecto y nombre único en Espacio. El proyecto por defecto para
  adaptadores viejos se identifica por **id**, en la variable de entorno `PROYECTO_POR_DEFECTO`, no por nombre. **[mi decisión]**
- **Posición 3D**: sigue siendo del nodo (`posX/Y/Z`); como cada nodo está en un solo proyecto, la vista de su proyecto
  la usa tal cual. La vista "todo" y los fantasmas usan un layout calculado, sin guardarlo. **[mi decisión]**
- **Tipos de nodo y de conexión**: ver §5b (decidido 2026-11-13).

## 5b. La API como base: tipos como datos **[Freddy, 2026-11-13: «la forma correcta y duradera»]**

Veredicto del 2026-11-13 (14 módulos de `src/`: 2 genéricos, 6 del método de trabajo, 6 mezcla): el núcleo (nodo,
conexión, descarte, bitácora, `bloqueado`/`libera`/`familia`) es genérico, pero el **vocabulario está fijo en el código**
(`schema.prisma:10-40`): 8 tipos de nodo de los cuales solo TAREA, DUDA y PERSONA sirven fuera de SIGSA; 5 tipos de
conexión de los cuales solo PERTENECE_A no bloquea; todo nodo obligado a ABIERTO/CERRADO. Cada uso nuevo (Mis máquinas,
conocimiento, salud) exigiría migración y código. Se descarta la alternativa barata (agregar valores a los enums).

- **Tabla `TipoNodo`** (por espacio): nombre, color, forma en la VR, `tieneCiclo` (abierto/cerrado o sin estado),
  `accionable` (entra a "hoy puedo"; reemplaza la constante `TIPOS_ACCIONABLES`). `@@unique([espacioId, nombre])`.
- **Tabla `TipoConexion`** (global, no por espacio: una conexión puede cruzar espacios y su significado no depende de cuál; decisión del plan, 2026-11-13): nombre, `bloquea` (lo usan `bloqueado`, `libera`, "hoy puedo"), `contiene`
  (lo usan `familia` y las agrupaciones, el papel de PERTENECE_A), `simetrica` (para "se relaciona con").
- **`Nodo.tipo` y `Conexion.tipo` pasan de enum a texto** validado por el servicio contra las tablas (sin FK: el código del método sigue comparando por nombre; decisión del plan FASE 22, 2026-11-13). `Nodo.estado` pasa a opcional: null si el tipo no tiene ciclo.
- **Plantillas al crear un espacio** **[mi decisión]**:
  - *empresa*: TAREA, DUDA, PERSONA · DEPENDE_DE, ESPERA_RESPUESTA_DE, BLOQUEADA_POR (bloquean), PERTENECE_A (contiene).
  - *máquinas*: MÁQUINA, FAMILIA, HERRAMIENTA (sin ciclo) · PERTENECE_A.
  - *conocimiento*: CONCEPTO, IDEA (sin ciclo) · SE_RELACIONA_CON (simétrica), DERIVA_DE.
  - *vacía*. Después, cualquier tipo se agrega desde la app sin migración.
- **El método de trabajo es una capa por espacio** (`Espacio.metodo`, hoy un solo valor: `trabajo-hu`). Roles,
  complementos, área, piezas, cara REAL/PLAN, etapas por rol, el día y las páginas por HU **no se reescriben**: se
  encienden solo en espacios con ese método, y buscan sus tipos (HISTORIA, FASE, RAMA, PR, DAILY_ITEM) por nombre dentro
  del espacio. SIGSA nace con `trabajo-hu` y sus 8 + 5 tipos de hoy como filas.
- **La fuente de Mis máquinas reutiliza `externoOrigen` + `externoId`** (`thinkpad` + `~/bin/README.md#buildworkspace`):
  ya es única y `aplicar-plan.ts` ya hace upsert por ese par, así la carga automática se puede repetir sin duplicar. El
  nodo no copia la descripción: la fuente vive en la máquina. **[Freddy, 2026-11-13]**
- **Salud espera a tener login y una marca de "sensible"**: hoy la API no autentica, `pino` loguea cada request, y
  `Cambio`/`Descarte` guardan copias completas en texto plano.

## 6. Migración

1. Migración de esquema: crear `Espacio` y `Proyecto`, agregar `Nodo.proyectoId` como opcional.
2. Migración aparte de datos (`CLAUDE.md` global §8): crear SIGSA → SAG, poner todos los nodos ahí, y recién entonces
   volver `proyectoId` obligatorio.
3. Los `Descarte` (JSON del nodo borrado) no tienen proyecto: al restaurar, si el JSON no trae `proyectoId`, vuelve a SAG.
4. **SIGSA queda visible, sin archivar.** **[Freddy, 2026-11-13: «hoy lo quiero ahí»]** Archivar un espacio tiene que
   existir en la API desde esta entrega, pero no se aplica a SIGSA. "Hoy puedo" filtrado por espacio evita que sus 151
   abiertos tapen lo de Mis máquinas.
5. Reescribir en el mismo cambio la regla global `~/.claude/CLAUDE.md` §18 ("cuelga de su HU o de su FASE; suelto cae en
   «Sin HU»", línea 423) como "cuelga de su proyecto; suelto cae en el General del espacio".
6. Reescribir la regla de `CLAUDE.md` §Trampas "el grafo de producción es el trabajo del SAG, nada más" en el mismo cambio:
   "cada mundo es un espacio; nada se mezcla sin espacio" (lo pedía la FASE 22).

## 7. Qué hay que tocar (investigación del 2026-11-12, ~49 puntos, varios agrupan archivos)

- **Esquema**: `prisma/schema.prisma:42-141` (Nodo, Descarte, Cambio).
- **API**: controladores nuevos de espacios y proyectos; `?proyecto=` y `?espacio=` en `GET /nodos`
  (`nodos.repository.ts:34`), `proyectoId` en `POST /nodos`, filtros en conexiones, ramas, piezas, complementos y pulido.
- **Derivados** (hoy todos globales): hoy-puedo (`derivado.repository.ts:77`), dia, paginas (`calcular-paginas.ts`),
  plan, ultimo-cambio, familia, bloqueado, libera.
- **Web**: selector de espacio/proyecto, tablero (`tablero.tsx:123-145`), crear-nodo, hooks de hoy-puedo, día, ramas,
  bloqueos; regenerar el cliente Orval.
- **VR**: `useMapaApi.ts:89-94` carga todo; `ultima-vista.ts` debe guardar por proyecto; `?proyecto=` en `parametros.ts:60`.
- **Importadores**: Todoist (`traducir.ts`), FASE (`importador-fases.service.ts`, sus `findFirst`/`startsWith` no tienen
  alcance), `aplicar-plan.ts`. Cada corrida recibe el proyecto destino **explícito** (argumento o clave en `refs.yaml`,
  por id) y sus búsquedas por título se limitan a ese proyecto. El mapeo actual (Todoist TRABAJO y PLAN, FASEs del
  Laboratorio) apunta a SAG. **[mi decisión]**
- **Quien escribe desde afuera**: los adaptadores `grafo` del Laboratorio (`Laboratorio/bin/adapters/grafo/`), su copia
  en `grafo-tareas/bin/adapters/grafo/` (**divergieron**: la del Laboratorio es más nueva), y los comandos que los llaman
  (`/flow:todo`, `/flow:observaciones`, `/flow:paircoding`, `/flow:pbi:*`, `/flow:daily`, `/flow:reunion`, el hook
  `fase-tilde.sh`, `~/bin/fase-tildar`, `~/bin/sesiones`).
  - Regla: un adaptador declara su proyecto con una clave nueva en `refs.yaml` (`tablero.proyecto`, por id). Si no la
    manda, la API usa `PROYECTO_POR_DEFECTO` (SAG) y **lo dice en la respuesta** (no silencioso). **[mi decisión]**
  - Antes de tocar los adaptadores, reconciliar las dos copias que divergieron: la del Laboratorio es la más nueva.

## 8. Lo que viene después (fuera de este diseño, anotado para no perderlo)

- **Primer espacio nuevo: Mis máquinas.** **[Freddy, 2026-11-13]** Sub-pestañas: ThinkPad, Mac Mini, PC Windows. Familias
  como nodos padre; cada herramienta = nombre + familia + fuente. Ejemplos de familias del ThinkPad: Herdr, Áreas
  (`buildworkspace`, `X`, `X-gh`), Chuletas (`hr`, `hh`, `ah`, `nvh`), Voz (`Ctrl+5`), Dashboards git (`pc-gh`, `mac-gh`),
  **Portar el método** (`nuevo-workspace`, `~/dotfiles/workspace-template`, `~/dotfiles/claude/PORTAR.md`: llevar un
  entorno tipo Laboratorio, con su git y su estructura de carpetas, a otra empresa). Mac Mini: Hermes, apps de `~/apps`.
- **Cartografía automática**: `cmd --json` local y por `ssh mac-mini` → nodos RECURSO; un lector de atajos
  (`media-keys.dconf`, input-remapper, `*-cheatsheet.txt`); LaunchAgents y `~/apps` del Mac. Windows: primero escribir qué hay.
- **Captura desde el teléfono**: agregar "grafo" como destino del triage de Reminders (`tools/reminders/shared/destinations.md`).
- **Respaldo fuera del Mac Mini**: hoy los 14 `pg_dump` viven en `deploy/respaldos/` de la misma máquina (`compose.yml:62-91`).
- **Ritmo de quincena**: el 1 y el 15 ya corre `/work:resume:sync` (timer `carrera-sync`); una revisión del grafo podría ir ahí.
- **`modo busqueda|laboral`** (`~/bin/modo`) podría elegir el espacio que abre el grafo.
- Tarea aparte: **repos por máquina** (`MAQUINA.md`, `instalar`, `~/.config/perfil` que no existe en ninguna máquina).

- **Cada espacio necesita quien escriba en él solo.** Medido el 2026-11-12: el grafo recibió ~119 nodos entre el 17 y el
  30 de octubre, mientras las sesiones de trabajo escribían solas, y nada desde el 30-10. Un espacio que depende de
  acordarse se muere. Mis máquinas lo cumple con su carga automática desde las fuentes de cada máquina.
- **Relación con la FASE 23** ("lo que entra también sale", `docs/backlog/FASE_23_EL_CICLO_DE_CIERRE.md:4`, que pedía ir
  antes que la 22): este diseño cubre su principio con el archivo de espacios y proyectos; falta decidir si la FASE 23 se
  reescribe o se cierra.

## 9. Decidido el 2026-11-13 (antes abierto)

1. Variante A del boceto: pestaña = espacio, sub-pestaña = proyecto.
2. SIGSA queda visible, sin archivar; archivar existe en la API para usarlo algún día.
3. Primer espacio nuevo: Mis máquinas.
4. Lo de `PORTAR.md` no es un conflicto: "portar" es el flujo de llevar el entorno tipo Laboratorio a otra empresa, y entra
   como familia del ThinkPad en Mis máquinas. (La pregunta de "instancias separadas" salió de leer una línea vieja de
   `PORTAR.md` y se descarta.)

## 10. Queda a criterio de quien lo construya

- Nombres exactos de endpoints, DTOs y componentes, siguiendo `docs/reglas-de-codigo.md`.
- Cómo se pinta el selector dentro de la variante que Freddy elija.
- El orden de las fases, siempre que la migración de datos vaya en un paso aparte y la web se pueda usar entre fases.

## 11. Revisión previa

Un revisor leyó este documento como si fuera a construirlo (2026-11-12) y trajo 8 preguntas: importadores, tipos del
método, vecinos de otro proyecto, mover/borrar, etapas por espacio, cómo se identifica el proyecto por defecto, posición
3D y semántica de lo archivado. Las 8 quedaron resueltas en §5 y §7 como **[mi decisión]**: ninguna cambiaba lo que
Freddy pidió, y cualquiera se puede revertir. La más grande es **etapas por espacio**, que adelanta algo que §3 dejaba
para después.
