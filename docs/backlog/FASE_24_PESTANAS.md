# FASE 24: PESTAÑAS DE ESPACIO Y PROYECTO, Y NODOS FANTASMA (web y VR)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking: tildar cada paso al cumplirlo, en este archivo, con su nota en cursiva.

**Destraba**: ver y trabajar cada mundo por separado (SIGSA, Mis máquinas, lo que venga) en la web y en el visor, sin
perder lo que los conecta. Sin esto, lo que la FASE 22 dejó en la API no se ve.
**Estado**: ✅ 8/8 tareas hechas y verificadas contra la API real local (2026-11-13); falta solo la revisión final, que lanza el orquestador.
**Azure**: no aplica (tracker: none)
**Tipo**: producto
**Dependencias**: FASE 22 (API de espacios, proyectos, tipos y vecinos), implementada y sin commitear. **La API no se
toca en esta FASE**: si algo falta en la API, parar y preguntar.
**Fuente**: Freddy, 2026-11-12/13: pestaña = espacio, sub-pestaña = proyecto (variante A del boceto); nodos fantasma.
**Spec**: `docs/superpowers/specs/2026-11-12-espacios-proyectos-design.md` — leer entero antes de empezar (§2, §5 y §9
sobre todo). Si el spec y este plan se contradicen, **parar y preguntar**: no elegir.

**Goal:** la web y la VR muestran los espacios como pestañas y sus proyectos como sub-pestañas; cada vista se filtra por
la pestaña elegida; lo que está conectado desde otro proyecto aparece atenuado con el nombre de su proyecto.

**Architecture:** el **alcance** (espacio y proyecto elegidos) vive en la URL (`?espacio=<id>&proyecto=<id>`) en la web y
en el estado Zustand + `ultima-vista` en la VR. Una función pura por lado traduce el alcance a los parámetros de la API
(`{ proyecto }` si hay proyecto, si no `{ espacio }`, si no nada). **Sin alcance = «Todo» = el comportamiento de hoy**:
nada cambia para quien no toca una pestaña. Los espacios sin método de trabajo (`metodo` null) no llaman a los endpoints
del método (día, páginas, plan, roles, ramas): tienen su propio tablero simple. Los fantasmas salen de
`GET /proyectos/:id/vecinos` y se marcan por `proyectoId` distinto al del proyecto activo.

**Tech Stack:** web: Next.js (App Router) + react-query (cliente Orval) + Tailwind v4 + vitest, **pnpm**. VR: React Three
Fiber + @react-three/xr + Zustand + vitest, **npm** (nunca pnpm).

## Restricciones globales (valen para todas las tareas)

- **Solo `grafo-tareas.web/` y `grafo-tareas.vr/`** (y en la Tarea 8, docs del orquestador). La API **no** se edita, ni su
  `openapi.json`; el cliente Orval ya está regenerado (FASE 22) y no se regenera.
- **Producción no se toca**: ni `bin/desplegar`, ni `bin/importar-en-produccion`, ni la API o base del Mac Mini.
- **Sin migraciones, sin instaladores, sin dependencias nuevas.** Si algo parece necesitar un paquete, parar y preguntar.
- **Sin commits, sin ramas, sin push.** Al final de cada tarea, en vez de commit, la verificación del repo tocado, toda
  verde, anotando los totales (denominador, regla global §12):
  - web (`grafo-tareas.web`): `pnpm lint && pnpm type-check && pnpm test:run`. Línea base: vitest 41/41 (13 archivos).
  - VR (`grafo-tareas.vr`): `npm run lint && npx tsc -p tsconfig.app.json --noEmit && npm run test:run`. Línea base:
    175/175 (25 archivos). **Nunca `npm run build` ni `vite build` en la VR** (reescribe `dist/`, que sirve el visor), y
    **nunca `pnpm` en la VR** (instala por su cuenta; ver `CLAUDE.md` §Trampas).
- **TDD:** la lógica nueva va en funciones puras con test (web: `src/lib/…`; VR: `src/lib/…`), y cada test se ve fallar
  antes de implementar; se anota el mensaje de la falla en el paso. Los componentes solo cablean esas funciones.
- **Sin `let`** (también en tests), **sin `any`**, constantes con nombre (web: `src/lib/constants/index.ts`; VR:
  `src/lib/constants/`), sin comentarios salvo una trampa de una línea, nombres de dominio en español.
- **Tipos del cliente generado** (`EspacioResponseDto`, `ProyectoResponseDto`, `TipoNodoResponseDto`, `NodoResponseDto`):
  no duplicarlos a mano.
- **Hooks de Orval**: params primero, options después (`useX(params, { query: { enabled } })`); la query key ya incluye
  los params, así que cambiar de pestaña refetchea solo. La invalidación global (`useInvalidarGrafo`, VR
  `invalidateQueries()`) ya cubre los hooks nuevos.
- **Texto 3D de la VR** siempre por `src/lib/texto-visible.ts` (sin emojis, largo acotado). `<Instances>` con capacidad
  fija y `frustumCulled={false}` (`CLAUDE.md` §Trampas).
- **Si algo falla dos veces igual, parar** y releer los archivos desde cero (regla global §0.1). Si sigue sin salir,
  dejar el paso sin tildar con `> BLOQUEADO: …` y seguir con lo que no dependa de él.

## Decisiones de este plan (no se reabren)

- **D1 · El alcance va en la URL en la web** (`?espacio=&proyecto=`): se comparte, sobrevive al recargar y no exige
  estado global. Los `Link` del menú (`NAVEGACION`, `src/app/layout.tsx:27-35`) lo conservan.
- **D2 · Pestañas** (variante A): fila de arriba = espacios no archivados por `orden` + una pestaña final **«Todo»**;
  fila de abajo (solo con un espacio elegido) = **«Todo el espacio»** + sus proyectos no archivados por `orden`, y un
  **«+»** al final de cada fila para crear (espacio: nombre + plantilla `empresa|maquinas|conocimiento|vacia`;
  proyecto: nombre). Archivar **no** tiene botón: es por API (Freddy, 2026-11-13). El color del espacio/proyecto, si
  existe, es el subrayado de su pestaña.
- **D3 · Un id que ya no existe** (en la URL o en `ultima-vista`: espacio archivado, borrado o de otra base) se descarta:
  la vista cae a «Todo» (o a «Todo el espacio» si solo falla el proyecto) y muestra un aviso de una línea. Nunca una
  pantalla vacía sin explicación (regla global §7).
- **D4 · La búsqueda cruza espacios** (spec §2.6): en el tablero, si hay texto de búsqueda (`q`), la consulta va **sin**
  alcance y la vista lo dice («buscando en todo»). El buscador de «conectar con…» (`conexiones-nodo.tsx:86`) también va
  sin alcance: las conexiones entre espacios están permitidas.
- **D5 · Espacio sin método** (`metodo` null): el menú oculta **El día** y **Ramas**; el tablero es el **tablero simple**
  (nodos del alcance agrupados por tipo, en el orden de `GET /espacios/:id/tipos-nodo`; los tipos con ciclo muestran su
  estado). «Hoy puedo» y «Bloqueos» funcionan con el alcance (la API ya filtra). En «Todo» y en espacios con método, el
  tablero es el de hoy, con el alcance en sus consultas.
- **D6 · Crear un nodo** con un espacio elegido: los tipos salen de `GET /espacios/:id/tipos-nodo` y las etapas de
  `EspacioResponseDto.etapas`; `proyectoId` = el proyecto activo, o el proyecto **General** del espacio en «Todo el
  espacio» (constante `NOMBRE_PROYECTO_GENERAL = 'General'`, el mismo nombre que la API). En «Todo», sin `proyectoId`
  (la API usa el proyecto por defecto, como hoy).
- **D7 · Mover un nodo** desde su detalle: selector con los proyectos **de su mismo espacio** → `PATCH /nodos/:id
  { proyectoId }`. Moverlo a otro espacio no se ofrece (la API responde 409 si el tipo no existe allá).
- **D8 · Fantasma** = nodo de **otro proyecto** que se muestra porque está conectado: atenuado y rotulado
  «`<proyecto>` · `<espacio>`» (+ «archivado» si su espacio o proyecto lo está). Se resuelve con un **directorio** de
  proyectos: `GET /espacios?archivados=true` (devuelve **todos**, también los archivados) + `GET /espacios/:id/proyectos
  ?archivados=true` por espacio → mapa `proyectoId → { proyecto, espacio, archivado }`.
- **D9 · En la VR, los fantasmas no guardan posición** (spec §5: «la vista todo y los fantasmas usan un layout
  calculado, sin guardarlo»): se ubican por el camino de los invitados (`ubicarFaltantes`/`separarNuevas`) y se excluyen
  del `PUT /nodos/posiciones`.
- **D10 · VR en un espacio sin método**: no hay páginas (`/derivado/paginas` es del método): el proyecto entero es **una
  página sintética** con todos sus nodos. «Todo» y los espacios con método siguen con las páginas de hoy.
- **D11 · Color por tipo en la VR**: `colorDe()` conserva su `switch` del método; un tipo que no conoce toma el `color`
  de su `TipoNodo` (de `GET /espacios/:id/tipos-nodo`) y, sin color, el de hoy. La **forma** por tipo queda fuera (hoy
  hay un solo `<Instances>` de esferas).

## Review Focus (lo que ningún test de tarea cubre por sí solo y más puede morder)

1. **Un id viejo en la URL o en `ultima-vista`** (espacio archivado o de otra base): aviso + «Todo», nunca pantalla vacía
   ni loop de requests → tests de `resolverAlcance` (Tarea 1) y `leerUltimaVista` (Tarea 5).
2. **Un espacio sin método** pidiendo día/páginas/plan/roles/ramas: la API da 404 y la vista no debe romperse; esas
   consultas ni se disparan (`enabled: false`) → Tarea 2 (web) y Tarea 5 (VR, página sintética).
3. **La búsqueda con una pestaña elegida** encuentra un nodo de otro espacio → test de `filtroDelTablero` (Tarea 2).
4. **Guardar posiciones con fantasmas en pantalla** no les pisa la posición de su propio proyecto → test de
   `posicionesAGuardar` (Tarea 7).
5. **«Todo» se comporta como hoy**: sin parámetros, las consultas salen idénticas a antes de la FASE → tests de
   `paramsDeAlcance` (Tarea 1) y verificación contra la API real (Tarea 8).

---

### Tarea 1: Web — el alcance en la URL y las pestañas

**Files:**
- Create: `grafo-tareas.web/src/lib/alcance/alcance.ts`, `alcance.test.ts`, `index.ts` (barrel)
- Create: `grafo-tareas.web/src/components/pestanas-alcance.tsx`, `src/lib/alcance/use-alcance.ts`
- Modify: `grafo-tareas.web/src/app/layout.tsx:27-36`, `src/lib/constants/index.ts:62-68` (`NAVEGACION`)

**Produces:**
- `type Alcance = { espacioId?: string; proyectoId?: string }`
- `leerAlcance(params: URLSearchParams): Alcance` — lee `espacio` y `proyecto`; un `proyecto` sin `espacio` se descarta.
- `paramsDeAlcance(a: Alcance): { proyecto?: string; espacio?: string }` — `{ proyecto }` si hay proyecto, si no
  `{ espacio }`, si no `{}`.
- `hrefConAlcance(ruta: string, a: Alcance): string` — la ruta con `?espacio=&proyecto=` (solo los presentes).
- `resolverAlcance(a: Alcance, espacios: EspacioResponseDto[], proyectos: ProyectoResponseDto[] | undefined):
  { alcance: Alcance; espacio?: EspacioResponseDto; proyecto?: ProyectoResponseDto; aviso?: string }` — D3. Con
  `proyectos === undefined` (aún cargando) no descarta el proyecto.
- `useAlcance(): { alcance, espacio?, proyecto?, aviso?, params, conMetodo: boolean }` — lee `useSearchParams`, pide
  `useEspaciosControllerFindAll()` y `useProyectosControllerListarDeEspacio(espacioId)` (`enabled` solo con espacio) y
  aplica `resolverAlcance`. `conMetodo` = sin espacio elegido, o espacio con `metodo` no null. `params` estable
  (memoizado: es parte de query keys).
- `NAVEGACION` suma `requiereMetodo: boolean` (El día y Ramas: `true`).

- [x] **Paso 1 (rojo):** `alcance.test.ts` con, al menos:
  - `leerAlcance(new URLSearchParams('espacio=e1&proyecto=p1'))` → `{ espacioId:'e1', proyectoId:'p1' }`;
    `'proyecto=p1'` → `{}`.
  - `paramsDeAlcance({})` → `{}` (D5: «Todo» = hoy); `{espacioId:'e1'}` → `{espacio:'e1'}`;
    `{espacioId:'e1',proyectoId:'p1'}` → `{proyecto:'p1'}`.
  - `hrefConAlcance('/hoy', {espacioId:'e1'})` → `'/hoy?espacio=e1'`; con `{}` → `'/hoy'`.
  - `resolverAlcance({espacioId:'x'}, [SIGSA], [])` → `alcance: {}` y `aviso` definido;
    `({espacioId:SIGSA.id, proyectoId:'x'}, [SIGSA], [SAG])` → `alcance: {espacioId:SIGSA.id}` y aviso;
    con proyectos `undefined` → conserva `proyectoId`, sin aviso.
  *Rojo visto: «Failed to resolve import "./alcance" from "src/lib/alcance/alcance.test.ts"» (módulo inexistente). 14 casos.*
- [x] **Paso 2:** implementar `alcance.ts` y `use-alcance.ts`.
  *Verde: 14/14. Sumé `ordenarPestanas` (filtra archivados y ordena por `orden`, no está en el plan) con 2 tests vistos en rojo («ordenarPestanas is not a function»): 16/16. `useAlcance` suma `cargando` (mientras `GET /espacios` no responde no se resuelve ni se avisa; `conMetodo` es false hasta saber) y `AVISO_ESPACIOS_NO_LEIDOS` si falla.*
- [x] **Paso 3:** `PestanasAlcance` (componente cliente) según D2, montado en `layout.tsx` entre el `<nav>` y el `<main>`,
  **dentro de `<Suspense>`** (un componente que usa `useSearchParams` sin `Suspense` rompe el build de Next). El aviso
  de `resolverAlcance` se muestra debajo de las pestañas. El «+» de espacio usa `useEspaciosControllerCreate` y el de
  proyecto `useProyectosControllerCreate`; al crear, navegar a la pestaña nueva. Los `Link` del menú usan
  `hrefConAlcance` y ocultan los `requiereMetodo` cuando `!conMetodo`. El menú también es cliente: extraerlo a un
  componente (`src/components/menu-principal.tsx`) en vez de volver cliente el layout.
  *Hecho: `menu-principal.tsx`, `pestanas-alcance.tsx` (fila espacios + «Todo» + «+», fila proyectos + «Todo el espacio» + «+»; color = subrayado), layout con `<Suspense>`. Las pestañas conservan la ruta actual (`usePathname`).*
- [x] **Paso 4:** verificación web verde (anotar totales).
  *`pnpm lint` limpio · `pnpm type-check` limpio · vitest 57/57 (14 archivos; base 41/13 + 16 nuevos).*

### Tarea 2: Web — cada vista con su alcance, y el tablero simple

**Files:**
- Create: `grafo-tareas.web/src/lib/grafo/filtro-del-tablero.ts` (+ test), `src/lib/grafo/agrupar-por-tipo.ts` (+ test),
  `src/app/tablero-simple.tsx`
- Modify: `src/app/tablero.tsx:76-145,222`, `src/app/hoy/hoy-puedo.tsx:7`, `src/app/dia/el-dia.tsx:35`,
  `src/app/bloqueos/bloqueos.tsx:40,45`, `src/app/ramas/ramas.tsx:25`, `src/app/page.tsx`

**Consumes:** `useAlcance()` (Tarea 1).
**Produces:**
- `filtroDelTablero(entrada: { params: {proyecto?,espacio?}; q?: string; libro?: string; rol?: string }):
  NodosControllerFindAllParams` — el filtro que hoy se arma inline en `tablero.tsx:127-135` (estado, notas, limit, cara,
  libro, rol, q) **más** el alcance; con `q` no vacío, **sin** alcance (D4).
- `agruparPorTipo(nodos: NodoResponseDto[], tipos: TipoNodoResponseDto[]): { tipo: TipoNodoResponseDto; nodos:
  NodoResponseDto[] }[]` — en el orden de `tipos`, omite grupos vacíos; un nodo cuyo tipo no está en `tipos` va a un grupo
  final con tipo sintético de nombre `Otros` (constante).

- [x] **Paso 1 (rojo):** tests:
  - `filtroDelTablero({ params:{proyecto:'p1'} })` incluye `proyecto:'p1'` y los campos de hoy; con `q:'login'` no trae
    ni `proyecto` ni `espacio` y sí `q`; con `params:{}` es **igual** al filtro de antes de la FASE (copiar el objeto de
    `tablero.tsx:127-135` como valor esperado).
  - `agruparPorTipo`: orden de `tipos`; grupo vacío omitido; tipo desconocido → grupo `Otros` al final.
  *Rojo visto: «Failed to resolve import "./filtro-del-tablero"» y «"./agrupar-por-tipo"» (módulos inexistentes). 10 casos (6 + 4).*
- [x] **Paso 2:** implementar las dos funciones.
  *Verde: 10/10. Constante nueva `NOMBRE_TIPO_OTROS`. Con `q`, el filtro omite el alcance; `rol: "todo"` no agrega rol.*
- [x] **Paso 3:** cablear el alcance:
  - `tablero.tsx`: `filtroDelTablero` en las consultas de tareas, fases y dudas; `useEtapasControllerLista(
    {espacio})` con el espacio activo; `useDerivadoControllerPaginas` y `useDerivadoControllerPlan` con `{espacio}` (el
    guard del método lee `?espacio=`) y `enabled: conMetodo`; con `q`, una línea «buscando en todo».
  - `page.tsx` (o el componente que monta el tablero): `conMetodo` ? tablero de hoy : `TableroSimple`.
  - `TableroSimple`: `useNodosControllerFindAll({...params, limit: LIMITE_TABLERO})` + `useTiposControllerListarNodo(
    espacioId)` + `agruparPorTipo`; cada nodo con su título enlazado a `/nodos/:id` (con `hrefConAlcance`) y su estado si
    el tipo tiene ciclo.
  - `hoy-puedo.tsx` y `bloqueos.tsx`: `params` del alcance. `el-dia.tsx` y `ramas.tsx`: `{espacio}` y `enabled:
    conMetodo` (el menú ya no los muestra, pero la URL directa no debe romper: mensaje «este espacio no usa el método de
    trabajo»).
  *Hecho. `Tablero` decide: cargando → «Cargando…», `conMetodo` → `TableroConMetodo` (el de hoy, con `{espacio}` en etapas/páginas/plan y `filtroDelTablero`), si no `TableroSimple`. Como las páginas/plan solo se montan con método, el `enabled: conMetodo` va por construcción; día y ramas sí llevan `enabled: conMetodo` y el mensaje «Este espacio no usa el método de trabajo.». `GET /ramas` no tiene parámetro de espacio. Hoy puedo y bloqueos pasan `params`. Aviso «Buscando en todo» solo con un espacio elegido.*
- [x] **Paso 4:** verificación web verde (anotar totales).
  *`pnpm lint` limpio · `pnpm type-check` limpio · vitest 67/67 (16 archivos).*

### Tarea 3: Web — crear con su espacio y proyecto, mover de proyecto

**Files:**
- Create: `grafo-tareas.web/src/lib/alcance/destino-de-creacion.ts` (+ test)
- Modify: `src/components/crear-nodo.tsx:26-96`, `src/app/nodos/[id]/nodo-detalle.tsx`, `src/lib/constants/index.ts`
  (`NOMBRE_PROYECTO_GENERAL`)

**Produces:**
- `destinoDeCreacion(alcance: Alcance, proyectosDelEspacio: ProyectoResponseDto[] | undefined): { proyectoId?: string }`
  — D6: proyecto activo; si solo hay espacio, el `General` de ese espacio; si no hay espacio, `{}`.

- [x] **Paso 1 (rojo):** tests de `destinoDeCreacion`: con proyecto → ese id; solo espacio → id del `General`; sin
  espacio → `{}`; espacio sin `General` en la lista (o lista `undefined`) → `{}` (la API decide; no inventar).
  *Rojo visto: «Failed to resolve import "./destino-de-creacion"». 5 casos, verde 5/5.*
- [x] **Paso 2:** implementar.
  *Hecho (`destino-de-creacion.ts`, constante `NOMBRE_PROYECTO_GENERAL`).*
- [x] **Paso 3:** `crear-nodo.tsx`: con espacio elegido, la lista de tipos es `useTiposControllerListarNodo(espacioId)`
  (nombres) y el tipo por defecto el primero; sin espacio, `TIPOS_NODO` de hoy. Las etapas, de `espacio.etapas` cuando
  hay espacio. `data` suma `proyectoId` de `destinoDeCreacion`. La conexión `PERTENECE_A` a la HU (`:46-52`) solo si
  `conMetodo`.
  *Hecho. Con espacio, tipos de `GET /espacios/:id/tipos-nodo` (si el elegido no existe en ese espacio, el primero); `proyectoId` de `destinoDeCreacion`; `PERTENECE_A` solo con `conMetodo`. Etapas: el componente sigue recibiendo `grupos`: `TableroSimple` los arma de `espacio.etapas`; el tablero con método conserva los grupos por rol (cubren las etapas del espacio, ver Ruling). `TableroSimple` monta `CrearNodo`.*
- [x] **Paso 4:** `nodo-detalle.tsx`: selector «Proyecto» (D7) con los proyectos del espacio del nodo
  (`useProyectosControllerListarDeEspacio`; el espacio del nodo sale del directorio de la Tarea 4 o de cruzar su
  `proyectoId`) → `useNodosControllerUpdate({ proyectoId })` + `useInvalidarGrafo`. Un 409 se muestra con el mensaje de
  la API.
  *Hecho en `components/selector-proyecto.tsx` (montado en el detalle). Se hizo después de los pasos 1-2 de la Tarea 4 porque el espacio del nodo sale del directorio. 409 se muestra con el mensaje de la API.*
- [x] **Paso 5:** verificación web verde (anotar totales).
  *`pnpm lint` limpio · `pnpm type-check` limpio · vitest 81/81 (18 archivos; incluye los 14 de `directorio.test.ts` de la Tarea 4 y los 5 de esta).*

### Tarea 4: Web — fantasmas en el detalle y en el tablero

**Files:**
- Create: `grafo-tareas.web/src/lib/alcance/directorio.ts` (+ test), `src/lib/alcance/use-directorio.ts`,
  `src/components/vecinos-de-otros-proyectos.tsx`
- Modify: `src/components/conexiones-nodo.tsx:28-76`, `src/app/tablero.tsx`, `src/app/tablero-simple.tsx`

**Produces:**
- `type EntradaDirectorio = { proyecto: string; espacio: string; espacioId: string; archivado: boolean }`
- `armarDirectorio(espacios: EspacioResponseDto[], proyectosPorEspacio: Record<string, ProyectoResponseDto[]>):
  Map<string, EntradaDirectorio>` — `archivado` = el proyecto **o** su espacio archivado.
- `rotuloFantasma(proyectoId: string, proyectoActivoId: string | undefined, dir: Map<…>): string | null` — `null` si
  `proyectoId` es el proyecto de referencia que se le pasa (o no hay referencia); si no, `«<proyecto> · <espacio>»` + `« · archivado»` cuando corresponde; id
  desconocido → `«otro proyecto»` (constante).
- `useDirectorio(): Map<…>` — `useEspaciosControllerFindAll({archivados:true})` + `useQueries` de
  `getProyectosControllerListarDeEspacioQueryOptions(id, {archivados:true})` (o el equivalente generado) por espacio.

- [x] **Paso 1 (rojo):** tests de `armarDirectorio` (archivado por proyecto y por espacio) y `rotuloFantasma` (mismo
  proyecto → `null`; otro → `'SAG · SIGSA'`; archivado → sufijo; desconocido → `'otro proyecto'`).
  *(Hecho antes de tiempo, ver Tarea 3 paso 4.) Rojo visto: «Failed to resolve import "./directorio"». 9 casos.*
- [x] **Paso 2:** implementar.
  *Verde 9/9: `directorio.ts` + `use-directorio.ts` (`combine` estable). Constantes `NOMBRE_OTRO_PROYECTO`, `SUFIJO_ARCHIVADO`.*
- [x] **Paso 3:** `conexiones-nodo.tsx`: en cada extremo, `rotuloFantasma(extremo.proyectoId, nodo.proyectoId, dir)`; si
  no es `null`, el extremo va atenuado (`opacity-50`) con el rótulo al lado. El nodo de referencia es el del detalle.
  *Hecho: cada extremo con otro `proyectoId` que el del detalle va con `opacity-50` y «(proyecto · espacio)» al lado. El buscador de «conectar» ya iba sin alcance (D4).*
- [x] **Paso 4:** `VecinosDeOtrosProyectos` (solo con un **proyecto** activo): `useDerivadoControllerVecinos(proyectoId)`;
  si hay, una sección «Conectado desde otros proyectos» al pie del tablero (de hoy y simple), cada uno atenuado, con su
  rótulo y enlace a su detalle.
  *Hecho: `components/vecinos-de-otros-proyectos.tsx`, montado en `Tablero` (cubre el de hoy y el simple); solo con proyecto elegido.*
- [x] **Paso 5:** verificación web verde (anotar totales).
  *`pnpm lint` limpio · `pnpm type-check` limpio · vitest 81/81 (18 archivos).*

### Tarea 5: VR — el alcance (estado, URL, última vista) y la carga por proyecto

**Files:**
- Modify: `grafo-tareas.vr/src/lib/estado-vr.ts:31-60`, `src/lib/parametros.ts:28-87` (+ test),
  `src/lib/ultima-vista.ts` (+ test), `src/App.tsx:51-64`, `src/escena/useMapaApi.ts:89-145`
- Create: `src/lib/alcance.ts` (+ test)

**Produces:**
- `estado-vr`: `espacioId: string | null`, `proyectoId: string | null`; acciones `verEspacio(id | null)` (pone
  `proyectoId: null`, `libro: 0`) y `verProyecto(id | null)` (pone `libro: 0`).
- `ParametrosPrueba` suma `espacio: string | null`, `proyecto: string | null` (`?espacio=&proyecto=`).
- `UltimaVista` suma `espacioId?: string`, `proyectoId?: string` (**opcionales**: lo guardado antes de la FASE sigue
  siendo válido).
- `alcance.ts`: `paramsDeAlcance({espacioId, proyectoId}): { proyecto?: string; espacio?: string }` (misma regla que la
  web) y `paginaUnica(nodos: Nodo[], titulo: string)` → una página con la forma que hoy usa `grafoDePagina`
  (`useMapaApi.ts:145`, ver `src/lib/paginas.ts`) con **todos** los ids (D10).
- Prioridad al arrancar: URL > `ultima-vista` > «Todo». Ids que no existen en `GET /espacios` / proyectos → D3 (aviso por
  `aviso` del estado, caer a «Todo»).

- [x] **Paso 1 (rojo):** tests: `leerParametros('?espacio=e1&proyecto=p1')` → esos campos; sin ellos → `null`.
  `leerUltimaVista` con un JSON viejo `{libro:2,cara:'REAL'}` → válido, sin espacio; con `espacioId: 5` (no string) →
  `null`. `paramsDeAlcance` (los tres casos de la web). `paginaUnica` con 3 nodos → una página con los 3 ids.
  *Rojo visto: «TypeError: useEstadoVr.getState(...).verEspacio is not a function», «Failed to resolve import "./alcance"», parametros «expected { fuente: 'api', nodos: 500, …(7) } to deeply equal {…(9)}» y ultima-vista «expected { libro: +0, cara: 'REAL' } to deeply equal {…(2)}». El caso de la vista vieja `{libro:2,cara:REAL}` pasó de entrada (es de compatibilidad, no puede ir en rojo). Sumé `resolverAlcance` (D3, Review Focus 1) con 5 casos, rojo «resolverAlcance is not a function», y un test de `verEspacio/verProyecto`.*
- [x] **Paso 2:** implementar estado, parámetros, última vista (guardar también espacio/proyecto) y `alcance.ts`.
  *Verde. `estado-vr` (`espacioId`, `proyectoId`, `verEspacio`, `verProyecto`: vuelven a HU 0, cara REAL, sin selección), `parametros.ts`, `ultima-vista.ts` (opcionales), `lib/alcance.ts` (`paramsDeAlcance`, `paginaUnica`, `resolverAlcance`) y `lib/constants/alcance.ts`.*
- [x] **Paso 3:** `useMapaApi.ts`: `useNodosControllerFindAll({ limit: LIMITE_GRAFO, ...paramsDeAlcance })`; el espacio
  activo (de `useEspaciosControllerFindAll()`) decide las páginas: con método o sin espacio → `/derivado/paginas` y
  `/derivado/plan` con `{espacio}` cuando hay espacio (el guard lee `?espacio=`); sin método → `enabled: false` en ambos
  y `paginaUnica(nodos, proyecto?.nombre ?? espacio.nombre)`. `ultimo-cambio` igual que hoy.
  *Hecho. `App.tsx`: URL > última vista > Todo (con `?espacio=` el libro arranca en 0) y se guarda espacio/proyecto. `useMapaApi`: nodos con `{proyecto|espacio}`, esperan a `GET /espacios` solo si hay espacio (Todo no espera nada, pide lo mismo); páginas/plan con `{espacio}`; sin método, `paginaUnica` y `ultimo-cambio` apagado (su id de página no existe en la API: Ruling); un id inexistente → `verEspacio/verProyecto` + `avisar`.*
- [x] **Paso 4:** verificación VR verde (anotar totales).
  *`npm run lint` limpio · `tsc -p tsconfig.app.json --noEmit` limpio · vitest 189/189 (26 archivos; base 175/25).*

### Tarea 6: VR — las pestañas en la barra superior

**Files:**
- Create: `grafo-tareas.vr/src/escena/BarraAlcance.tsx`, `src/lib/filas-de-alcance.ts` (+ test)
- Modify: `src/escena/BarraSuperior.tsx:36-82`, `src/lib/constants/` (lo que haga falta: `TEXTO_TODO`,
  `TEXTO_TODO_EL_ESPACIO`, `MAX_PESTANAS_FILA`, separación entre filas)

**Produces:**
- `filasDeAlcance(espacios, proyectos, alcance): { espacios: Pestana[]; proyectos: Pestana[] }` con
  `type Pestana = { id: string | null; texto: string; activa: boolean }` — D2 sin el «+» (crear es de la web): fila 1 =
  espacios no archivados por `orden` + «Todo» (`id: null`); fila 2 (vacía sin espacio) = «Todo el espacio» (`id: null`)
  + proyectos no archivados por `orden`. Cada fila se corta en `MAX_PESTANAS_FILA` (lo que no cabe en la banda; medir con
  `ANCHO_BOTON`) y el texto pasa por `textoVisible`.

- [x] **Paso 1 (rojo):** tests de `filasDeAlcance`: orden, archivados fuera, «Todo» activa sin alcance, fila 2 vacía sin
  espacio, corte en `MAX_PESTANAS_FILA`.
  *Rojo visto: «Failed to resolve import "./filas-de-alcance"». 6 casos.*
- [x] **Paso 2:** implementar.
  *Verde 6/6. `Pestana` suma `color` (para `colorResaltado`). `MAX_PESTANAS_FILA = 12` (≈ 90° a 2,9 m con botones de 0,45 m); la fila se desplaza para no perder la activa, y «Todo» / «Todo el espacio» ocupan siempre un lugar.*
- [x] **Paso 3:** `BarraAlcance`: dos filas de `Boton3D` (`resaltado` = activa, `colorResaltado` = color del
  espacio/proyecto si tiene) **encima** de la fila de HU de `BarraSuperior`; tocar = `verEspacio(id)` / `verProyecto(id)`.
  La fila de HU solo se muestra con método (en un espacio sin método hay una sola página). Nada nuevo en DOM: dentro del
  visor solo existe el 3D.
  *Hecho. `useAlcanceVr` (alcance contra lo que tiene la API; lo comparten el mapa y las barras), `medidas-barra.ts` (la altura y distancia de la barra, antes locales de `BarraSuperior`), `BarraAlcance` montada en `App.tsx`. La fila de HU desaparece sola en un espacio sin método: `BarraSuperior` pide las páginas con `enabled: conMetodo`. No se probó en el visor (Freddy).*
- [x] **Paso 4:** verificación VR verde (anotar totales).
  *`npm run lint` limpio · `tsc -p tsconfig.app.json --noEmit` limpio · vitest 195/195 (27 archivos).*

### Tarea 7: VR — fantasmas y color por tipo

**Files:**
- Modify: `grafo-tareas.vr/src/lib/dominio.ts:5-24,56`, `src/lib/desde-api.ts:12-76` (+ test), `src/lib/colores.ts:17-55`
  (+ test), `src/escena/useMapaApi.ts:104,197-208`, `src/escena/Grafo.tsx:121-130`, `src/escena/Etiquetas.tsx`
- Create: `src/lib/posiciones-a-guardar.ts` (+ test) si la lógica de `useMapaApi.ts:197-208` no está ya en una función
  pura (si está, testear esa y modificarla).

**Produces:**
- `Nodo` suma `proyectoId: string` y `fantasma: string | null` (el rótulo, o `null`). `Nodo.tipo` pasa a `string`: las
  constantes `TipoNodo`/`TipoConexion` quedan para **comparar** (son los nombres del método), y se borran los casts de
  `desde-api.ts:12-16` (el comentario «hasta la FASE 24» se va con ellos).
- `aGrafo(nodos, conexiones, vecinos?: NodoResponseDto[], rotulo?: (proyectoId) => string)` — los vecinos entran como
  nodos con `fantasma = rotulo(proyectoId)`, así sus conexiones dejan de filtrarse (`desde-api.ts:55`). Un vecino que ya
  vino en `nodos` no se duplica.
- `colorDe(nodo, …, colorPorTipo?: Map<string, string>)` — D11.
- `posicionesAGuardar(...)` excluye los nodos con `fantasma` (D9).
- Rótulo: mismo formato y directorio que la web (`«<proyecto> · <espacio>»`, `« · archivado»`, `«otro proyecto»`):
  `src/lib/directorio.ts` con `armarDirectorio` y `rotuloFantasma` (mismas firmas que la web, Tarea 4; es otro repo, no
  hay paquete compartido: copiar la lógica con sus tests es aceptable acá).

- [x] **Paso 1 (rojo):** tests: `aGrafo` con un vecino de otro proyecto → está en `nodos` con `fantasma` y su conexión se
  conserva; vecino repetido → una sola vez. `colorDe` de un tipo `HERRAMIENTA` con `colorPorTipo` → ese color; sin mapa
  → el de hoy; `TAREA` → igual que hoy. `posicionesAGuardar` con un fantasma movido → no lo incluye. `rotuloFantasma` y
  `armarDirectorio` (los de la web).
  *Rojo visto: «expected [ 'tarea' ] to deeply equal [ 'tarea', 'herramienta' ]» (aGrafo), «expected '#94a3b8' to be '#22c55e'» (colorDe), «Failed to resolve import "./posiciones-a-guardar"» y «"./directorio"». 16 casos nuevos (aGrafo 3, colores 3, posiciones 3, directorio 7); los de «sin mapa/sin vecinos/TAREA igual que hoy» son de regresión y pasaron de entrada.*
- [x] **Paso 2:** implementar.
  *Verde. `Nodo.tipo` y `Conexion.tipo` son `string`; `proyectoId` y `fantasma` quedan **opcionales** como el resto de los campos extra de `Nodo` (Ruling: evita reescribir ~10 fixtures sin ganar nada). Casts y el comentario «hasta la FASE 24» de `desde-api.ts` borrados. `posicionesAGuardar` se extrajo de `useMapaApi` (no estaba en función pura). `conRotulo` en `directorio.ts`: «(proyecto · espacio) título».*
- [x] **Paso 3:** cablear: con un **proyecto** activo, `useDerivadoControllerVecinos(proyectoId)` y el directorio
  (`useEspaciosControllerFindAll({archivados:true})` + proyectos por espacio) en `useMapaApi`; `Grafo.tsx` aplica
  `colorApagado` a los fantasmas siempre (mismo draw call, sin material transparente); `Etiquetas.tsx` agrega el rótulo
  al título del fantasma (por `textoVisible`). `colorPorTipo` desde `useTiposControllerListarNodo(espacioId)`.
  *Hecho: `useMapaApi` (vecinos con proyecto elegido, directorio, `colorPorTipo` del espacio, fantasmas sumados a la página y fuera del guardado; en un espacio sin método `paginaUnica` no los cuenta), `Grafo.tsx` (fantasmas con `colorApagado` siempre), `Etiquetas.tsx` (rótulo). `Seleccion.tsx` no lleva el rótulo (no estaba en el plan).*
- [x] **Paso 4:** verificación VR verde (anotar totales).
  *`npm run lint` limpio · `tsc -p tsconfig.app.json --noEmit` limpio · vitest 211/211 (29 archivos).*

### Tarea 8: Verificación contra la API real, e2e de la web y docs

**Files:** `grafo-tareas.web/e2e/*` (solo mocks), `docs/backlog/README.md`, este archivo, `CLAUDE.md` (§Trampas, solo
si apareció una trampa nueva).

- [x] **Paso 1:** e2e de la web: con la web servida en 3001 (`pnpm dev --port 3001` o `bin/dev`),
  `PW_CHANNEL=chrome pnpm test:e2e`. Los specs existentes mockean la API con `page.route`; si alguno falla porque ahora
  se pide `/espacios`, `/espacios/*/proyectos` o `/tipos-*` sin mock, agregar esos mocks (un helper compartido en
  `e2e/`), **sin** cambiar lo que cada spec afirma. Agregar un spec nuevo `e2e/pestanas.spec.ts`: dos espacios mockeados
  (uno con método, otro sin) → se ven las pestañas, tocar el sin método oculta «El día» y la URL lleva `?espacio=`.
  Anotar totales.
  *Hecho. Los 5 specs existentes no necesitaron mocks nuevos (sin espacio elegido no piden `/espacios/*/proyectos` ni `/tipos-*`; `GET /espacios` sin mock falla y no molesta). Nuevo `e2e/pestanas.spec.ts` (2 tests: pestañas + URL + El día/Ramas ocultos en el espacio sin método; un espacio inexistente cae a Todo con aviso). Rojo visto cambiando a propósito la lista esperada: «Expected - 0 / Received + 1». Totales: 8 pasan, 1 falla: `tablero-roles.spec.ts:88` busca `/llegó sin columna/`, texto que NO existe en `src` ni en `QUE_SIN_ETAPA` de `HEAD` (`66c804c` lo reemplazó por «notas, preguntas y capturas sueltas…»): falla previa a la FASE 24, ver Ruling; no se tocó la aserción.*
- [x] **Paso 2:** contra la API **real local** (no se mockea: un parámetro nuevo se prueba contra la API real,
  `CLAUDE.md`). `bin/dev` (API 3000 + web 3001, base local `grafo_tareas`). Con `curl`:
  `POST /api/v1/espacios {nombre:'Prueba FASE 24', plantilla:'maquinas'}` → `POST /espacios/:id/proyectos
  {nombre:'ThinkPad'}` → dos nodos `HERRAMIENTA` en ThinkPad y una `FAMILIA` → una conexión `PERTENECE_A` entre ellos y
  una conexión de una HERRAMIENTA a una TAREA de SAG (`GET /nodos?tipo=TAREA&limit=1`; el tipo de conexión debe existir en
  `GET /tipos-conexion`, usar `PERTENECE_A` si no hay otro neutro). Anotar los ids.
  *Hecho (2026-11-13, tras desbloquear: fase22 ya terminó). `bin/dev` arrancó API 3000 + web 3001. Creados por `curl`: espacio «Prueba FASE 24» (plantilla `maquinas`, tipos FAMILIA/HERRAMIENTA/MAQUINA), proyecto ThinkPad, 2 HERRAMIENTA (`buildworkspace`, `pc-gh`) y 1 FAMILIA («Dashboards git»), 2 `PERTENECE_A` herramienta→familia y 1 conexión `buildworkspace` → TAREA 25327 de SAG con `SE_RELACIONA_CON` (existe en `GET /tipos-conexion`; el plan pedía `PERTENECE_A` solo si no había otro neutro). Medido: `GET /nodos?espacio=` → 3; `GET /proyectos/<SAG>/vecinos` → 1 (`buildworkspace`) y `/proyectos/<ThinkPad>/vecinos` → 1 (la TAREA); `GET /derivado/hoy-puedo?espacio=` → `[]`; `GET /derivado/paginas?espacio=<sin método>` → **404** (por eso la web y la VR no lo piden); `GET /nodos?q=buildworkspace` sin alcance → 1 (la búsqueda cruza espacios); `GET /nodos?limit=1` → total 228 con los 3 de prueba (225 sin ellos).*
- [x] **Paso 3:** con Playwright (script en el scratchpad o `npx playwright` del repo web, **sin** dependencias nuevas),
  capturas de pantalla a `/tmp/fase24/`: (a) `/` sin parámetros (debe verse como antes); (b) pestaña «Prueba FASE 24» →
  tablero simple agrupado por tipo; (c) sub-pestaña ThinkPad; (d) el detalle de la TAREA de SAG mostrando la HERRAMIENTA
  como fantasma «ThinkPad · Prueba FASE 24»; (e) `/hoy?espacio=<Prueba>` vacío sin error. Revisar cada captura antes de
  tildar. VR: `npm run dev` (puerto 5173, el que acepta CORS) y una captura de
  `http://localhost:5173/?espacio=<id>&proyecto=<id>` fuera del modo inmersivo; si el WebGL headless no dibuja, anotarlo
  y no forzar (Freddy lo prueba en el visor).
  *Hecho: `/tmp/fase24/` (8 PNG; las 6 de la web revisadas una a una, y las 2 de la VR). (a) `a-todo`: el tablero de siempre (Sin columna 47, ENTENDIMIENTO 23, roles, HU) con la fila «Prueba FASE 24 · SIGSA · Todo · +» y todo el menú; (b) `b-espacio-tablero-simple`: FAMILIA 1 / HERRAMIENTA 2, menú sin El día ni Ramas, sub-pestañas «Todo el espacio · General · ThinkPad · +»; (c) `c-subpestana-thinkpad`: lo mismo y, al pie, «Conectado desde otros proyectos»: la tarea 25327 atenuada con «SAG · SIGSA»; (d) `d-detalle-tarea-sag-fantasma`: en Conexiones, «buildworkspace (ThinkPad · Prueba FASE 24)» atenuado; (e) `e-hoy-espacio-vacio`: «Nada libre: todo espera algo.» sin error; extra `f-proyecto-invalido-aviso`: un proyecto de otro espacio cae a «Todo el espacio» con «Ese proyecto ya no existe…». Consola del navegador sin errores. Defecto visto y arreglado: los «+» salían subrayados en negro (`border-transparent`). VR con `npm run dev` en 5173 y WebGL por swiftshader: `vr-a-todo` (sin parámetros: pide `/nodos?limit=500` y `/derivado/paginas` sin parámetros nuevos; fila de pestañas + fila de HU) y `vr-b-proyecto` (`?espacio=&proyecto=`: dos filas de pestañas sin fila de HU, pide `/nodos?limit=500&proyecto=`, `/proyectos/:id/vecinos` y `/espacios/:id/tipos-nodo`; dibuja 3 nodos + el fantasma «(SAG · SIGSA) …», 4 nodos / 3 aristas, 52 FPS). La TAREA de SAG no cambió: `updatedAt` 2026-10-17 y su posición intacta, o sea el fantasma no guardó.*
- [x] **Paso 4:** limpiar lo creado en el Paso 2 en la base local: borrar las conexiones y los nodos de prueba,
  `DELETE /proyectos/<ThinkPad>`, `DELETE /proyectos/<General>` y `DELETE /espacios/<Prueba>` (o, si algún DELETE da
  409, `PATCH /espacios/<Prueba> {archivado:true}` y anotarlo). Apagar `bin/dev` (`bin/dev --parar`) y el `npm run dev`
  de la VR.
  *Hecho: DELETE de las 3 conexiones y 3 nodos (204), de ThinkPad y General (200) y del espacio (200, sin 409). Verificado: `GET /espacios?archivados=true` → solo SIGSA; nodos 225; la TAREA de SAG vuelve a sus 2 conexiones `PERTENECE_A`. `bin/dev --parar` y el vite de la VR parados: nada escucha en 3000, 3001 ni 5173.*
- [x] **Paso 5:** docs: fila de la FASE 24 en `docs/backlog/README.md`; trampas nuevas (si hubo) en `CLAUDE.md`
  §Trampas, una línea cada una; llenar el **Informe de implementación** al final de este archivo.
  *Hecho: fila del README (🟡 7/8), una trampa en `CLAUDE.md` (`bin/dev` con otro agente en la API) y el Informe de abajo.*

## Criterios de aceptación

- [x] 1 · Sin tocar ninguna pestaña, la web y la VR piden lo mismo que antes de la FASE (mismos parámetros, misma vista).
  *Verificado: en la web, `filtroDelTablero({params:{}})` = el filtro de antes (test) y la captura `a-todo` se ve como antes; en la VR, `vr-a-todo` pide `/nodos?limit=500` y `/derivado/paginas` sin parámetros nuevos.*
- [x] 2 · Web: las pestañas de espacio y las sub-pestañas de proyecto filtran tablero, hoy puedo y bloqueos; el día y
  ramas solo existen en espacios con método; se crean espacios y proyectos desde la app.
  *Verificado con tests, e2e (API simulada) y contra la API real local (capturas b, c, e). Crear espacio o proyecto con un clic real no se probó contra la API: solo el código y el tipo de la mutación.*
- [x] 3 · Un nodo conectado desde otro proyecto se ve atenuado con «proyecto · espacio», en el detalle y en la VR.
  *Verificado contra la API real: capturas c y d (web) y `vr-b-proyecto` (VR); en el visor lo prueba Freddy.*
- [x] 4 · VR: con un proyecto elegido, el mapa trae solo ese proyecto y sus fantasmas, y los fantasmas no guardan
  posición.
  *Verificado contra la API real: `vr-b-proyecto` pide solo `?proyecto=` + vecinos y la TAREA fantasma no guardó posición. Probado en WebGL de escritorio, no en el visor.*
- [x] 5 · web y VR: lint, type-check y tests verdes, cada test nuevo visto en rojo primero; e2e de la web verdes; la API
  sin cambios (`git -C grafo-tareas.api status` igual que al empezar).
  *Verificado: lint, type-check y tests verdes en los dos (web 87/87, VR 211/211), cada test nuevo visto en rojo, e2e de la web 9/9 (el viejo `tablero-roles.spec.ts:88` se actualizó, ver el Informe). A la API no la toqué (`git status` pasó de 100 a 102 líneas por fase22, que la editaba en paralelo).*

## Fuera de alcance

- La API (cualquier cambio → parar y preguntar).
- Crear el espacio real Mis máquinas y su carga automática → FASE 25.
- Forma por tipo en la VR (D11), editar o archivar tipos/espacios desde la UI, reordenar pestañas.
- `bin/probar-en-visor` y cualquier `vite build`: probar en el Quest lo hace Freddy.
- Recordar la última pestaña en la web (la URL alcanza por ahora).

## Informe de implementación

**Estado: las 8 tareas hechas y los 5 criterios tildados. Pendiente: la revisión final de la rama (la lanza el orquestador, no esta sesión).**

**Totales finales** (corridos al terminar, después del último cambio)
- Web (`pnpm lint && pnpm type-check && pnpm test:run`): limpio · limpio · **87/87, 19 archivos** (base 41/13). e2e (`PW_CHANNEL=chrome pnpm test:e2e`): **9/9**; `pnpm build` (`next build --webpack`): verde; los 2 tests de `pestanas.spec.ts` se vieron fallar a propósito.
- VR (`npm run lint && npx tsc -p tsconfig.app.json --noEmit && npm run test:run`): limpio · limpio · **211/211, 29 archivos** (base 175/25).
- Sin dependencias nuevas (`package.json` y lockfiles sin diff), sin commits, sin `vite build` ni `pnpm` en la VR, API sin editar.
- Contra la API real local (tarea 8): ver pasos 2-4 más arriba. Capturas en **`/tmp/fase24/`**: `a-todo`, `b-espacio-tablero-simple`, `c-subpestana-thinkpad`, `d-detalle-tarea-sag-fantasma`, `e-hoy-espacio-vacio`, `f-proyecto-invalido-aviso` (web) y `vr-a-todo`, `vr-b-proyecto` (VR, escritorio). La base local quedó como estaba (225 nodos, solo SIGSA) y los servidores parados.

**Desvíos del plan y por qué** (cada uno tiene su `Ruling:` en el ledger `.superpowers/sdd/FASE_24_PESTANAS/progress.md`)
1. Web: `useAlcance` suma `cargando` y `AVISO_ESPACIOS_NO_LEIDOS`, y existe `ordenarPestanas` (con test): mientras `GET /espacios` no responde no se resuelve el alcance (sin 404 de los endpoints del método ni avisos falsos).
2. Web: el paso 4 de la tarea 3 (selector de proyecto) se hizo después de los pasos 1-2 de la tarea 4 (directorio): el espacio del nodo sale de ahí.
3. Web: `CrearNodo` sigue recibiendo `grupos`; en un espacio sin método los arma `TableroSimple` de `espacio.etapas`, y con método quedan los grupos por rol (más finos para SIGSA; `GET /etapas` ya viene con `{espacio}`). D6 decía «de `espacio.etapas`» en general.
4. VR: se sumó `resolverAlcance` (con test) para el id viejo de la URL o de `ultima-vista` (Review Focus 1), el hook `useAlcanceVr` (lo comparten el mapa y las barras) y `medidas-barra.ts` (altura y distancia de la barra, antes locales de `BarraSuperior`).
5. VR: `Nodo.proyectoId` y `Nodo.fantasma` son **opcionales**, no `string` / `string | null` como pedía el plan (mismo estilo que los demás campos extra y evita reescribir fixtures). `ultimo-cambio` se apaga en un espacio sin método (el plan decía «igual que hoy»; la página sintética no existe en la API).
6. **Test viejo, no de la FASE 24:** `tablero-roles.spec.ts:88` buscaba `/llegó sin columna/`, un texto que no existe en `src` desde el commit `66c804c` de la web (la columna «Sin columna» dice hoy `QUE_SIN_ETAPA`: «notas, preguntas y capturas sueltas: en Todoist no tienen sección…»). Con tu OK se cambió la regex a `/en Todoist no tienen sección/` (verificado contra `constants/index.ts:42`); afirma lo mismo —que cada columna dice qué significa—.
7. Tarea 8: primero la bloqueó el permiso de `bin/dev` (fase22 trabajaba la API); con tu OK se corrió completa. La conexión de prueba hacia la TAREA fue `SE_RELACIONA_CON` y no `PERTENECE_A`.
8. Cambio fuera de plan por un defecto visto en la captura: los «+» de las pestañas salían subrayados (`border-transparent` en `ESTILO_PESTANA`).

**«1 Issue» de Next en `c-subpestana-thinkpad.png` — lo causaba la FASE 24 (arreglado).** Se reprodujo con `bin/dev` + los mismos datos de prueba y Playwright (`pageerror`): aparecía en **cada carga completa** (también en `/`), no solo en la pestaña c. Texto exacto: `Hydration failed because the server rendered text didn't match the client. As a result this tree will be regenerated on the client.` con el diff `<Pestana … texto="Prueba FAS..." activa={false}>`: cliente `+ Prueba FASE 24`, servidor `- Todo` (y `- aria-current="page"`, `- href="/"`). Causa: las pestañas y el menú están en un `<Suspense>` (por `useSearchParams`) y su hidratación llega después de que otro componente ya llenó la caché de `GET /espacios`; el cliente pintaba los espacios en su primera pasada y el HTML del servidor no los traía. Arreglo: `useHidratado` / `useDatosHidratados` (`lib/alcance/use-hidratado.ts`) —los datos de la API se ven recién tras hidratar— usados en `useAlcance` y `PestanasAlcance`; test `use-hidratado.test.tsx` (hidrata de verdad con `hydrateRoot`: el caso sin el cuidado produce el error recuperable, el cuidado no). Repetido el flujo a→e: 0 «Issue», 0 `pageerror`; `c-subpestana-thinkpad.png` se volvió a tomar (las demás capturas de la web son anteriores al arreglo y llevan el mismo «Issue»).

**Defecto de build encontrado de paso (también de la FASE 24, arreglado):** `pnpm build` fallaba con `useSearchParams() should be wrapped in a suspense boundary at page "/dia"`: `useAlcance` lo usan las páginas, no solo el menú, y el `<Suspense>` del layout solo cubría el menú y las pestañas. Habría roto `bin/desplegar`. Arreglo: `<Suspense>` también sobre `{children}` en `layout.tsx`; `pnpm build` verde (`/`, `/dia`, `/hoy`, `/bloqueos`, `/ramas` estáticas; `/nodos/[id]` dinámica). El dev no lo avisa: solo el build.

**Arreglado a pedido (no era del plan):** `TEXTO_CONEXION` no tenía `SE_RELACIONA_CON` ni `DERIVA_DE` y el detalle leía «buildworkspace (…) este» sin verbo. Ahora los tiene («se relaciona con», «deriva de») y `textoDeConexion` (`lib/grafo/describir-conexion.ts`, función pura, 4 tests vistos en rojo) muestra el nombre del tipo en minúscula y con espacios («ES_PARTE_DE» → «es parte de») si llega uno sin texto; `describirConexion` la usa. El selector de «conectar» ofrece ahora también los dos tipos nuevos. Queda sin hacer lo más duradero: leer los tipos de `GET /tipos-conexion` en vez de una tabla fija.

**Sin verificar**: lo visual dentro del visor (pestañas, fantasmas atenuados, las dos filas de la barra; Freddy lo prueba en el Quest) y crear un espacio o proyecto desde el «+» con un clic real.

**Archivos a revisar, en orden de importancia**
1. `grafo-tareas.vr/src/escena/useMapaApi.ts` (~96-200, 284): el alcance en las consultas, la página sintética, los fantasmas y el guardado; es donde un error rompe el visor entero.
2. `grafo-tareas.web/src/lib/alcance/use-alcance.ts` (24-50) y `alcance.ts` (47-65): `cargando`, `conMetodo`, el id inexistente → Todo con aviso.
3. `grafo-tareas.web/src/app/tablero.tsx` (79-130) y `src/lib/grafo/filtro-del-tablero.ts`: que «Todo» pida lo mismo que antes y que buscar cruce espacios.
4. `grafo-tareas.vr/src/lib/desde-api.ts` (19-50), `colores.ts` (20), `posiciones-a-guardar.ts`: fantasmas, color por tipo, qué no se guarda.
5. `grafo-tareas.web/src/components/pestanas-alcance.tsx` y `menu-principal.tsx`; `grafo-tareas.vr/src/escena/BarraAlcance.tsx` y `src/lib/filas-de-alcance.ts`: las pestañas.
6. `grafo-tareas.web/src/components/crear-nodo.tsx` (~40-100), `selector-proyecto.tsx`, `conexiones-nodo.tsx` (35-60), `vecinos-de-otros-proyectos.tsx`.
7. `grafo-tareas.vr/src/App.tsx` (52-80) y `lib/estado-vr.ts`, `parametros.ts`, `ultima-vista.ts`.
8. `grafo-tareas.web/e2e/pestanas.spec.ts` y las constantes nuevas de `src/lib/constants/index.ts` (al final).
