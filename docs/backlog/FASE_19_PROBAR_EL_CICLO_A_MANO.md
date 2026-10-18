# FASE 19: PROBAR EL CICLO A MANO (DEL LABORATORIO AL VISOR)

**Destraba**: que Freddy compruebe, trabajando su próxima task real, que cada paso del Laboratorio llega a la web y a la VR
como debería, y arreglar lo que esa mirada ya encontró
**Listo para PR**: no · el guion se usa con la próxima task; el arreglo de `fase-tildar` (Tarea 2) está hecho; la pasada de
las 10 tarjetas en Todoist (Tarea 3) espera el «sí» de Freddy
**Prioridad**: Alta para el arreglo (es lo que más confunde hoy en el tablero); el guion, cuando toque
**Dependencias**: FASE 13 (árbol HU → FASE → tarjeta), FASE 17 (dos caras)
**Fuente**: Freddy, 2026-10-18: «verificar de una prueba end-to-end de que las cosas funcionan bien»; y después: «la prueba
end-to-end, en general, yo pienso que se refiere a yo probando que todo funcione como debería… necesitamos más pruebas… pero
que no sean tan rígidas… hay que tener cuidado con lo que vamos a agregar»

## Por qué a mano y no un runner

Un runner que levante la API, la web y la VR sobre un Laboratorio de mentira es caro de construir y de mantener, y si
interpreta mal un paso hay que rehacerlo entero. Cada capa ya tiene sus pruebas:
- **API:** 117 unit y 54 e2e.
- **Web y VR:** Playwright.
- **Adaptador del tablero:** 31 casos.

Lo que faltaba mirar es la costura entre las capas, y eso lo mira Freddy con sus datos reales. **Una prueba automática nueva
entra solo cuando un defecto real la pide, y chica:** el caso que falló, nada más.

## El guion (con la próxima task real)

El grafo se entera al importar. Después de cada paso hay que correr `bin/importar-en-produccion todoist --proyecto
6VhFQg6v45qcJHPc` y, si cambió una FASE, `… fases ~/Volumes/Siigsa/SAG/Proyectos/Laboratorio --proyecto laboratorio`
(las dos primero con `--seco`).

| # | en el Laboratorio | en la web (Trabajo, pastilla de la HU) | en la VR (página de la HU) |
|---|---|---|---|
| 1 | `/flow:pbi:get <id>` | la tarjeta `[id]` colgando de su HU | aparece en la página de la HU |
| 2 | `/flow:pbi:understand` | la tarjeta en ENTENDIMIENTO; la FASE con Entendimiento ✓ | — |
| 3 | colección → auditoría → guía | Collection Created → TESTEADO → LISTO PARA PR | — |
| 4 | `/flow:tildar` mergeado | la FASE con `mergeada` | el dedo 2 la apaga |
| 5 | quedan URL commit y evidencias | esas tarjetas en TRÁMITES DE CIERRE | el dedo 3 las apaga |
| 6 | `/flow:pbi:repartir` → Draft | Plan: una columna por carril | la cara PLAN (la hoja se da vuelta) |
| 7 | — | clic derecho «Mover a Trabajo» en una pieza | la pieza cambia de cara |

Lo que no se vea como dice la tabla se anota abajo, en § Lo que encontró mirar, con la captura. Se arregla en la fuente, no
con una regla nueva en la API.

## Lo que encontró mirar (2026-10-18, producción)

Las **10 tarjetas `[FASE n]` de Todoist** (FASE 22-30 y 37, todas de calidad) están en columnas viejas y sin `calidad`.
Su FASE ya está en RED (9 de ellas mergeadas). Son las «FASE 24, 27, 28» que Freddy no entendía en Producto, y la tarjeta en
AMARRAR que vio ahí.

| FASE | la tarjeta `[FASE n]` | la FASE (`.md`) |
|---|---|---|
| 22 | APROBADO | Pull Request · mergeada |
| 23, 29, 30 | TESTEADO | RED · mergeada |
| 24, 28 | Pull Request | RED · mergeada |
| 25, 26, 27 | LISTO PARA PR | RED · mergeada |
| 37 | AMARRAR 🧰 | RED (14 de 16 tareas) |

**Por qué:**
- La columna de una tarjeta de calidad la recalcula el hook `fase-tilde` (`~/.claude/hooks/fase-tilde.sh`), y el hook solo
  corre en el `PostToolUse` de `Write|Edit` de Claude Code (`~/.claude/settings.json:36`).
- Su último registro, `~/.claude/state/fase-calidad.tsv`, dice **AMARRAR** para la FASE 30 y la 37. La misma regla, corrida
  hoy sobre la FASE 37, da **red**: después de esas tildes, el hook no volvió a correr.
- No queda registrado cómo se tildaron. Lo que sí se sabe es que el hook se salta todo lo que no sea un `Edit` o un `Write` de
  Claude Code:
  - `fase-tildar`, la lapicera de `/flow:tildar`, que tilda desde Bash y tampoco mueve la tarjeta (no nombra `tablero` ni
    `etapa`);
  - un script;
  - otra herramienta;
  - el editor.

Esto reemplaza la propuesta (b) de la HU 19565 («las tarjetas de una FASE mergeada no antes de APROBADO»): no hace falta una
regla nueva, sino que la fuente se mueva cuando cambia su FASE.

### Ensayo del corte (2026-10-18, paso 4 del plan de la FASE 5)

El adaptador `grafo` se corrió contra producción desde una copia de la configuración del Laboratorio, con tarjetas de prueba que
después se borraron (222 nodos antes y después). Ni Todoist ni el `refs.yaml` real se tocaron.

- ✅ **Las 5 operaciones funcionan:** `pendiente`, `buscar`, `tarjeta` (idempotente: la segunda vez dice «existía»), `etapa`
  (movida a Collection Created) y `borrador`.
- 🔧 **Arreglado: con el Mac Mini caído, `pendiente` y `tarjeta` salían 0 sin haber guardado nada.**
  - Causa: sin conexión, curl escribe el código `000`, y `_gr_curl` (`bin/adapters/grafo/lib/tablero.sh`) solo tomaba como error
    `≥ 400`. Además, `tarjeta` y `etapa` imprimían el resultado dentro de un `printf "$(…)"`, que se tragaba la falla.
  - Ahora solo un 2xx es éxito, y sin conexión se dice «sin conexión con <api>».
  - Prueba: `api_caida_pendiente` y `api_caida_tarjeta` en `bin/tests/test_tablero.sh`, vistas en rojo antes del arreglo;
    33/33 en verde. El adaptador de Todoist no tiene este defecto: `~/bin/lib/todoist-api.sh:126` ya solo acepta 2xx.
- ✅ **Arreglado: `borrador` no dejaba la pieza como la deja el importador.** Quedaba en la cara REAL, solo con la etiqueta
  `borrador`, sin `pieza` ni `ronda:N`, colgada de una rama sin la etiqueta `carril` y sin su HU, y la vista Plan no la veía.
  - La regla salió de `traducir.ts` a `src/importadores/pieza.ts`, sin cambiarla. Lo prueban las 52 pruebas del importador,
    entre ellas la de que es determinista.
  - La usan el importador y la ruta nueva `POST /piezas`. Si el carril ya existe, se reusa con su mismo origen, así la columna
    no sale dos veces.
  - Prueba: `test/piezas.e2e-spec.ts`, 3 casos. Ahora la especificación es obligatoria, porque de su cabecera sale la HU.
  - Hasta que se despliegue la API, el adaptador no la puede usar contra producción; se despliega antes del corte.
- ✅ **Arreglado: `tarjeta` no reconocía la pieza que se toma.** Si el plan ya tiene la pieza con ese id en el título, ésa pasa
  a trabajo (cara REAL, primera etapa, la etiqueta del contrato y el motivo en la bitácora): sale `tomada`, y queda una sola
  tarjeta (C12). En Todoist no se notaba porque la tarjeta se movía a mano y conservaba su id. Prueba: 4 casos en
  `test_tablero.sh`, 37/37.
- ✅ **Arreglado: `fase-tildar` no movía la tarjeta.** Ahora, después de tildar, llama al mismo hook con el aviso de un `Edit`.
  Prueba: `~/bin/tests/test_fase_tildar.sh`, 4 casos, vistos en rojo.
- ✅ **Arreglado: el importador tomaba «Thomas» por Carabantes** (`ALIAS_PERSONAS`). Ahora es Tomás Soto, con su prueba.
- ⏳ **No es agnóstico, y queda propuesto:** las personas del cliente (Carabantes, Soto, Fabián) están escritas en el código
  del importador. Deberían vivir en el `refs.yaml` del área, como las escaleras de dudas (C11: «las personas son del
  cliente»).

## El arreglo (para aprobar)

- **`fase-tildar`**, después de tildar, llama al mismo `fase-tilde.sh` con el JSON de un `Edit` sobre esa FASE. Así la regla
  de qué columna le toca a la tarjeta sigue viviendo solo en el hook.
- **Una sola prueba**, la del caso que falló: tildar `listo` en una FASE de calidad de mentira mueve su tarjeta en un tablero
  falso. Se ve en rojo antes del arreglo y en verde después; sin red, sin Todoist.
- **Las 10 tarjetas de hoy**: una pasada del mismo hook por las FASE de calidad. El hook ya es idempotente: solo mueve si la
  columna cambió desde su registro. La pasada escribe en Todoist, así que va con su propio «sí».

## Decisiones del agente (para revisar al leer)

- **D1 · La prueba de punta a punta es el guion, a mano**, como lo pidió Freddy. No se construye un runner.
- **D2 · El arreglo va en la fuente (`fase-tildar`) y reusa el hook.** Ni una regla nueva en la API, ni una segunda copia de la
  regla de columnas.
- **D3 · Lo que se agrega en pruebas es un caso**, en el estilo de las de `~/bin/tests/`. Afirma qué columna recibe la
  tarjeta, no cómo se ve.

## Understand

- [x] Entendimiento — 2026-10-18: medido en producción (las 10 tarjetas), regla del hook corrida sobre la FASE 37, cableado
  del hook leído en `~/.claude/settings.json:36`, `fase-tildar` (y su `FASE_DIR`, que deja probarlo aparte) leído

## Tareas

### Tarea 1: el guion
- [ ] Freddy lo recorre con su próxima task real; lo que no se vea como dice la tabla queda en § Lo que encontró mirar

### Tarea 2: el arreglo de `fase-tildar` (con su «sí»)
- [x] `fase-tildar` llama a `fase-tilde.sh` tras tildar, con su caso de prueba visto en rojo y en verde — 2026-10-18:
  `~/bin/tests/test_fase_tildar.sh` 4/4, en rojo antes del arreglo (la tarjeta no se movía)

### Tarea 3: las 10 tarjetas (con su «sí»: escribe en Todoist)
- [ ] La pasada del hook por las FASE de calidad, y reimportar TRABAJO en seco: 0 tarjetas `[FASE n]` en otra columna que la de
  su FASE

## Criterios de Aceptación

- [ ] 1 · Freddy recorrió el guion con una task real, y lo que no se vio quedó anotado acá
- [ ] 2 · Ninguna tarjeta `[FASE n]` en una columna distinta de la de su FASE, en producción
- [ ] 3 · La única prueba nueva es la del caso que falló

## QA

- [ ] Colección — no aplica
- [ ] Auditoría — no aplica
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
