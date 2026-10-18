# FASE 19: PROBAR EL CICLO A MANO (DEL LABORATORIO AL VISOR)

**Destraba**: que Freddy compruebe, trabajando su próxima task real, que cada paso del Laboratorio llega a la web y a la VR
como debería, y arreglar lo que esa mirada ya encontró
**Listo para PR**: no · el guion se usa con la próxima task (Tarea 1); el arreglo de `fase-tildar` (Tarea 2) y la pasada de
las 10 tarjetas (Tarea 3) están hechos
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
- ✅ **Agnóstico: las personas salieron del código** (Freddy: «dale»). Viven en `personas:` del `refs.yaml` del área, como
  las escaleras de dudas (C11: «las personas son del cliente»). `leerArea` las valida y `AreaService` las entrega, y el
  importador las recibe: sin esa clave no crea ninguna. En `src` no queda ningún nombre del cliente, tampoco en los ejemplos de
  Swagger. Pruebas: `leer-area.spec.ts` y `traducir.spec.ts` (sin área no inventa personas), y la e2e del importador con su
  `refs.yaml` de fixture.

### La pasada de las 10 tarjetas (2026-10-18, con el «sí» de Freddy)

- ✅ **FASE 37: movida en Todoist de AMARRAR a RED** con el hook real; reimportar dio 1 actualizada y 0 nuevas, en seco y en real.
- ✅ **Las 10 llevan `calidad` en el grafo** (PATCH con motivo): salen de Producto, que es lo que confundía.
- ⛔ **Las otras 9 NO se movieron, porque habría sido llevarlas hacia atrás.** Están mergeadas, pero su FASE no lo refleja:
  - la FASE 22 tiene tildado «Listo para PR», y le faltan las casillas del cierre en Azure;
  - las FASE 23 a 30 no tienen tildados «Listo para PR» ni todas sus tareas.

  La regla de calidad (`docs/roles.yaml`, igual a la plantilla) deriva APROBADO del cierre en Azure, no de la casilla
  `Mergeado`, que se agregó después. Por eso las deja en RED o en Pull Request, cuando en Todoist ya están más adelante
  (TESTEADO, LISTO PARA PR, Pull Request, APROBADO).
- ✅ **Resuelto en la regla** (Freddy delegó la decisión: «haz esto»). Se descartó tildar en la fuente, porque habría
  afirmado tareas sin tildar que no se pueden verificar (a la FASE 30 le faltaban 13 casillas). Se eligió la regla, porque
  `Mergeado` se creó para ser esa señal (FASE 17).
  - `roles.yaml` (área y plantilla): `aprobado` de producto y calidad pasa a `si: { qa: Mergeado }`. Medido antes con
    `test_roles.py` sobre las 35 FASE: cambian esas 9, todas hacia APROBADO, y las otras 26 quedan iguales.
  - El hook `fase-tilde` (su copia de la regla de calidad): si `Mergeado` está tildada, la columna es APROBADO.
    `test_fase_tildar.sh`, 5 casos, vistos en rojo. Con el cambio de `fase-tildar`, una tilde de cierre habría devuelto
    la FASE 22 a Pull Request.
  - `tablero.secciones` del Laboratorio y del bloque `grafo`: la sección `aprobado: APROBADO`.
  - En producción, desplegado el 2026-10-18 (api `d47e4f7`, orquestador `05e8821`, respaldo previo
    `grafo-2026-10-18_2010.dump`):
    - importar las fases: 9 actualizadas y 0 nuevas (lo mismo en seco);
    - el hook movió 8 tarjetas a APROBADO en Todoist; la 22 ya estaba;
    - reimportar TRABAJO: 8 actualizadas y 0 nuevas;
    - resultado: **0 de 10** tarjetas `[FASE n]` en otra columna que la de su FASE.
  - Queda una deuda: la regla de columnas de calidad vive en dos lugares, `roles.yaml` y el Python del hook. Hoy coinciden
    en APROBADO, pero el hook no lee `roles.yaml`.

### Lo que dejó el corte (2026-10-18)

- ✅ **Las 10 tarjetas `[FASE n]` congeladas, descartadas** (con el «sí» de Freddy), cada una con su motivo: la tarjeta de una
  FASE de calidad es su nodo FASE. Antes de descartar se leyeron enteras: su título estilo commit ya está en git (los merges de
  `develop` del BFF) para las FASE 22 a 30; el de la FASE 37, que todavía no tiene commit, pasó a su Tarea 16.
- ✅ **Trámites normalizados, un solo nodo por FASE** (con el «sí» de Freddy). «Listo para PR» tildado en las FASE 23 a 30
  (mergeadas: el PR existió); la URL commit de la FASE 23, tildada después de verla en Azure (GET de la 26307). Importar fases
  generó sus trámites. Las 8 tarjetas de Todoist por FASE no se descartaron sin más: llevaban los links y el texto de Evidencias
  listo para pegar, que se copió a la descripción del trámite de su FASE (`PATCH` con motivo; el importador lo respeta, medido en
  seco: 0 por actualizar). Recién después se descartaron. Las agrupadoras («🟣 Cierres pendientes» y «Agregar URL commit… 12») y
  «editar la wiki por los cambios de 23697» se quedan: no las cubre ningún trámite de FASE.
- ⏳ **Al contrato le falta «crear con descripción».** `/sigsa:sonarqube:entregar` necesita la tarjeta en ENTENDIMIENTO con su
  texto: hoy usa `etapa` y después `PATCH` de la descripción. Si otro comando lo pide, se agrega como operación del contrato.

### Freddy en el visor (2026-10-18, HU 19565, build `index-XwwoaPKg`)

Lo que vio, y la causa medida en el código y en producción (las citas `archivo:línea` son de la VR en `19aa13c`, antes
del arreglo: `git -C grafo-tareas.vr show 19aa13c:src/<archivo>`). Lo arreglado, con su «dale, aplica las mejoras», va en
§ Arreglos del visor; el orden de lo suelto (lista B) espera su «sí» por número.
- **Con el filtro 1 «no hay hilos» HU → FASE; con el 2 sí.** No se pierden: con el 1 el árbol se dibuja con opacidad 0.4
  (`OPACIDAD_ESTRUCTURA`) y la pertenencia a una rama con 0.08; con el 2, lo encendido va con 0.9 (`escena/Grafo.tsx:120-142`).
- **[26750] gris y lejos «aunque es un PBI».** Es la tarjeta `[id]` de un PBI sin FASE todavía (`Tareas/26750` bajado, sin
  `FASE_*.md`): un TAREA sin carril se pinta `COLOR_SIN_RAMA` (`lib/colores.ts:27`), y su único hilo va a la HU. La VR no distingue
  la tarjeta de un PBI de una nota.
- **[26317] Husky esencial «¿es FASE?».** No: es la tarjeta `[26317]`, cuelga de la FASE 30, y está **vieja**: la FASE 30 está
  mergeada (APROBADO) y la tarjeta sigue en ENTENDIMIENTO, abierta. Vino así de Todoist.
- **«Para la daily: el husky…» sin color propio.** Es un DAILY_ITEM (`complemento:para-decir`, `EN_DAILY_DE` → «Daily»): el
  modelo lo tiene; la VR lo pinta como cualquier tarea. Además, 5 TAREA traen la etiqueta `daily` y 6 la `retro` en vez de ser
  «para decir» de su ritual (`GET /area`: daily y retro): el mismo concepto, dos formas.
- **«[correcciones viejas]…» y las 6 «01-oct · retro: …» «no sé qué son».** Las correcciones son un trámite real de Azure
  (vincular/desvincular PR), hija de «🟣 Cierres pendientes». Las retro son propuestas de proceso: cuelgan de FASE 1, 6, 7, 8 y 13
  porque **citan** sus números como ejemplo (PERTENECE_A por mención), y por eso caen en la página de la HU 19565.
- **Tomás Carabantes: «Libre: nada lo frena».** Es su nodo PERSONA (le esperan 8 dudas abiertas). El texto de la selección
  pregunta qué frena al nodo (`lib/seleccion.ts:7`): para una persona la pregunta es al revés, quién la espera.
- **El rayo cuesta.** Es el de `@react-three/xr` por defecto (`createXRStore({ emulate: false })`, `App.tsx:31`), que se desvanece.
- **Gestos que estorban.** La pose de apuntar cuenta como 1 dedo (y el 1 es «ver todo»); el pellizco del pulgar con el índice y
  el gesto del menú de Meta no se descartan (`lib/conteo-dedos.ts:46`). Es la calibración pendiente de la FASE 17.
- **De fondo, palabras de Freddy:** *«siento que tengo basura que nunca supe ordenar… ahora que la tengo no sé cómo mostrar la
  información»*. En producción hay 21 TAREA abiertas sin etiqueta: notas sin «qué es».
- **Lo que se mide al venir:** R3 del importador de fases (`engancharTarjetas`) cuelga de una FASE **toda TAREA que cite su
  task en el título**, en cada importación: por eso las retro caen en la HU 19565, y borrar ese hilo a mano no sirve (vuelve).
  R3 solo mira TAREA: lo que pase a «para decir» (DAILY_ITEM) deja de engancharse. El tipo de un nodo no se edita (`update-nodo.dto.ts`):
  convertir = crear el nuevo y descartar el viejo (se restaura).

### Arreglos del visor (2026-10-18, build `index-kLK2-wiS`, cargado y verificado en el visor)

- ✅ **Hilos sin filtro**: árbol 0.4 → 0.75 y relaciones 0.6 → 0.85 (`lib/constants/grafo.ts`). El 1 era y sigue siendo el filtro
  apagado (FASE 17 tarea 7: «1 = todo (por defecto)… sin filtro no se apaga nada»); lo raro era que se viera más tenue que el 2.
- ✅ **Morado = PBI** (`lib/pbi.ts`, del título: `[<id>]` de la tarjeta, ` · <task>` al final de la FASE). La tarjeta y la FASE que
  se encuentran, lavanda; la que no —**tarjeta sin FASE** (en producción: 25682, 26469, 26750) o **FASE sin task** (la 36)— en
  fucsia y más grande que una FASE, y al seleccionarla dice «PBI a medias: sin FASE / FASE sin task». Lo cerrado no está a medias.
- ✅ **«Para decir»** (DAILY_ITEM) con color propio, cian, en la leyenda. Y en la **entrada**: `pendiente informe|confirmacion`
  del adaptador ya no crea una TAREA con `daily`, crea un DAILY_ITEM `complemento:para-decir` EN_DAILY_DE el ritual `daily` de
  `GET /area` (el mismo nodo «Daily» que usa la API, por su externo `ritual/daily`); sin ese ritual en el área, sale 1 sin escribir.
  Es el gancho que pidió Freddy: `/flow:todo` ya obliga a elegir el tipo; el adaptador lo guarda como lo que es.
- ✅ **Persona seleccionada**: «La esperan N — se iluminan alrededor» (lo abierto con ESPERA_RESPUESTA_DE hacia ella, en la página).
- ✅ **Rayo sólido** de la mano y del control: `MeshBasicMaterial`, opacidad 1, hasta la pantalla curva (`RADIO_PANORAMA`).
- ✅ **Gestos**: el índice solo ya no es un número (es apuntar); ver todo = el número del filtro puesto otra vez (o B); el menú de
  Meta —palma hacia la cara y pellizco— no es ningún número (`esGestoDeMeta`). El 3 («OK») junta pulgar e índice: por eso no se
  ignora todo pellizco, solo el de la palma hacia la cara. **SUPUESTO**: el signo de la normal de la palma (test rojo probado
  invirtiéndola, pero la orientación real de las articulaciones del Quest se confirma con `?depurar`, campo `meta`).
- Gates: VR unit 133 · e2e 3 · tsc 0 · lint 0; `bin/tests/test_tablero.sh` 42/42 (5 nuevos, rojos probados volviendo `informe` a
  TAREA). Contra producción, sin escribir: `nodo_de_ritual daily` encontró el «Daily» existente; destapó que `q=` vacío da 400 en
  la API real y el backend falso lo aceptaba (arreglado: sin texto, no se manda).
- ⏳ **`vence` daba 500 al crear y al editar** (encontrado aplicando la lista B, punto 23): el DTO documenta `YYYY-MM-DD` y el
  servicio se lo pasaba tal cual a Prisma, que pide fecha con hora. Así `/flow:todo … --vence` fallaba en producción (avisando,
  sin escribir) y el backend falso no lo veía. Arreglo en `nodos.service.ts` (`conVenceComoFecha`, crear y editar) + e2e en
  `pulido.e2e-spec.ts`, rojo visto (`Expected 201, Received 500`). API unit 120 · e2e 58 · tsc 0 · lint 0. **Falta desplegar**:
  commit, push y `bin/desplegar` (de Freddy). Mientras, la fecha completa (`…T00:00:00.000Z`) funciona.
- ✅ **Lista B, puntos 21-25** (con sus respuestas): 21 propuesta con su explicación · 22 cerrada (ya la revisó) · 23 p1, vence
  19-10 · 24 propuesta, para Fabián · 25 observación con su idea. Cada edición con motivo en la bitácora.

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
- [x] La pasada del hook por las FASE de calidad, y reimportar TRABAJO en seco: 0 tarjetas `[FASE n]` en otra columna que la de
  su FASE — 2026-10-18: 0 de 10, con la regla de `Mergeado` (§ La pasada de las 10 tarjetas)

## Criterios de Aceptación

- [ ] 1 · Freddy recorrió el guion con una task real, y lo que no se vio quedó anotado acá
- [x] 2 · Ninguna tarjeta `[FASE n]` en una columna distinta de la de su FASE, en producción — 0 de 10, medido el 2026-10-18
- [ ] 3 · La única prueba nueva es la del caso que falló

## QA

- [ ] Colección — no aplica
- [ ] Auditoría — no aplica
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
