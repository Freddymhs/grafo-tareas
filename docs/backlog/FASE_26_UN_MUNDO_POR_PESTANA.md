# FASE 26: UNA PESTAÑA, UN MUNDO: SIN «TODO» Y CON LA LEYENDA DE CADA ESPACIO

**Destraba**: usar Mis máquinas (y cualquier espacio nuevo) en el visor sin el ruido del método del SAG: sin «Todo», sin
«Todo el espacio», y con una leyenda y unos filtros que hablan de los tipos de ese espacio.
**Estado**: sin rama
**Azure**: no aplica (tracker: none)
**Tipo**: producto
**Dependencias**: FASE 24 (pestañas), FASE 22 (tipos como datos)
**Fuente**: Freddy en el Quest, 2026-11-13: «como pestaña padre debería existir solamente mis máquinas, personal y
zigzag… todo no tiene sentido… demasiado ruido visual» · «Mis máquinas tiene todo el espacio y general. No entiendo por
qué hay dos tabs» · sobre los filtros: «la función está casi perfecta, pero… ahora quizás no son PBI»

## El hueco, medido

Medido el 2026-11-13 en el visor, con el build de la FASE 24 y la API de producción:
- **La fila de espacios suma «Todo»**, que mezcla todos los mundos (`grafo-tareas.vr/src/lib/filas-de-alcance.ts:58-59`,
  `TEXTO_TODO` en `lib/constants/alcance.ts`). La web hace lo mismo (`NOMBRE_TODO`/`NOMBRE_TODO_EL_ESPACIO` en
  `grafo-tareas.web/src/lib/constants/index.ts:112`).
- **La fila de proyectos siempre empieza con «Todo el espacio»** (`filas-de-alcance.ts:65-73`). En Mis máquinas, que
  tiene un solo proyecto (General), salen dos pestañas que muestran lo mismo.
- **La leyenda de la VR es la del SAG en todos los espacios** (`escena/BarraSuperior.tsx:59-68`: «HU», «PBI», «PBI a
  medias», «borde = sin task en Azure»…). Los filtros 1-4 (`lib/filtro.ts`) también corren en todos lados; el 3
  («sin trámites») es del cierre en Azure.
- La parte de datos ya se arregló a mano (2026-11-13): el espacio «Personal» pasó a llamarse «Mis proyectos», y su
  General vacío se archivó, así que ya no aparece.

## Las decisiones

### D1 · La fila de espacios lleva solo espacios — Freddy, 2026-11-13 `[negocio]`

- Sin «Todo».
- Sin espacio elegido (primera vez, URL sin `?espacio=`, o el id ya no existe), se ve el **primero por `orden`**.
- Reemplaza la D2 y la D3 de la FASE 24 en lo que dicen de «Todo».
- **Web:** el «+» para crear un espacio se queda.

### D2 · La fila de proyectos lleva solo proyectos, y solo si hay dos o más — Freddy, 2026-11-13 `[negocio]`

- Sin «Todo el espacio».
- **Con 0 o 1 proyecto vigente**, la fila no se muestra y se ve el espacio entero (`proyectoId` null por dentro). Es el
  caso de Mis máquinas.
- **Con 2 o más**, la fila se muestra. Sin proyecto elegido, se ve el **primero por `orden`**.
- Un proyecto vacío **se muestra** igual: se esconde archivándolo por la API, no adivinando. Si no, uno recién creado
  desde el «+» de la web desaparecería.
- **Web:** la D6 de la FASE 24 («General» en «Todo el espacio») pasa a ser «el proyecto activo o, sin fila, el único
  vigente».

### D3 · Fuera del método, la VR usa los tipos del espacio — Freddy, 2026-11-13 `[negocio]`

Espacio con método (`metodo` no nulo, hoy SIGSA): **todo como hoy**, porque ahí «PBI» y «Azure» son correctos.

Espacio sin método:

- **Leyenda:** un ítem por tipo de `GET /espacios/:id/tipos-nodo`, en ese orden, con el color de `colorDe` (D11 de la
  FASE 24). Se suma «chica = cerrada» solo si algún tipo `tieneCiclo`.
- **Filtros:**
  - si algún tipo tiene ciclo: 1 = todo, 2 = pendiente, 4 = lo que frena;
  - el 3 («sin trámites») no existe;
  - si ningún tipo tiene ciclo (Mis máquinas): no hay filtros. Los dedos y el botón B no hacen nada, y la leyenda no
    nombra filtros.
- **Una sola fuente para la regla:** una función pura, `filtrosDelEspacio(conMetodo, tipos) → readonly Filtro[]`, en
  `lib/filtro.ts`. `filtroAlMostrar`, `siguienteFiltro` y la leyenda la consultan; no se duplica un `if` por componente.

## Abierto

Ninguno.

## Understand

- [x] Entendimiento — lo de arriba, medido en el visor el 2026-11-13

## Tareas

### `grafo-tareas.vr`
- [x] **Tarea 1** · `lib/filas-de-alcance.ts` + test: D1 y D2. Salen `TEXTO_TODO` y `TEXTO_TODO_EL_ESPACIO` si quedan
  sin uso. Test rojo primero.
- [x] **Tarea 2** · `lib/alcance.ts` (`resolverAlcance`) + `escena/useAlcanceVr.ts` + `lib/estado-vr.ts`: el alcance
  efectivo nunca es «Todo». Sin espacio, o con uno inexistente, cae al primero con aviso; con fila de proyectos y sin
  proyecto, al primero. Test rojo primero. Revisar `ultima-vista.ts` y `parametros.ts`.
- [x] **Tarea 3** · `lib/filtro.ts` (`filtrosDelEspacio`) + `escena/BarraSuperior.tsx`: D3. La leyenda sin método sale de
  los tipos; los filtros, de `filtrosDelEspacio`. Test rojo primero en `filtro.test.ts` y en la leyenda si hay test.

### `grafo-tareas.web`
- [x] **Tarea 4** · `src/lib/alcance/` + `src/components/pestanas-alcance.tsx`: D1 y D2. Se actualizan los tests y el e2e
  `e2e/pestanas.spec.ts`, incluidos los que afirmaban «Todo».

## Criterios de Aceptación

- [x] 1 · VR y web: la fila de espacios muestra Mis máquinas, Mis proyectos y SIGSA, sin «Todo».
- [x] 2 · Mis máquinas: no hay fila de proyectos y se ven sus nodos. SIGSA: «SAG · General», con SAG elegido al entrar.
- [x] 3 · En Mis máquinas la leyenda dice MAQUINA, FAMILIA y HERRAMIENTA, y no hay filtros. En SIGSA, todo igual que
  antes de esta FASE.
- [x] 4 · VR (`npm run lint && npx tsc -p tsconfig.app.json --noEmit && npm run test:run`) y web (`pnpm lint && pnpm
  type-check && pnpm test:run`, e2e con `PW_CHANNEL=chrome pnpm test:e2e`) en verde. Cada test nuevo, visto en rojo.

## Fuera de alcance

- La API: no cambia. Si algo la pide, se para y se pregunta.
- Contar los nodos de un proyecto para esconder los vacíos (D2: se archiva).
- `bin/probar-en-visor`: el visor lo levanta la sesión que orquesta.

## QA

- [ ] Listo para PR
- [ ] Mergeado

## Cierre oficial en Azure

- [ ] URL commit — no aplica
- [ ] Evidencias
- [ ] Wiki actualizada — no aplica

## Informe de implementación

**Estado: las 4 tareas hechas.** Los criterios 1-3 son visuales: se tildaron contra tests (unit en los dos repos y el e2e
de la web con la API simulada), **no** contra el visor ni la API real. Falta verlos en el Quest y en la PWA desplegada.

**Totales** (corridos al final, después del último cambio)
- VR (`npm run lint && npx tsc -p tsconfig.app.json --noEmit && npm run test:run`): limpio · limpio · **232/232, 30
  archivos** (base 211/29). Cada test nuevo se vio en rojo antes del código.
- Web (`pnpm lint && pnpm type-check && pnpm test:run`): limpio · limpio · **96/96, 19 archivos** (base 87/19). e2e
  (`PW_CHANNEL=chrome pnpm test:e2e`): **9/9**. Los 2 tests nuevos de `pestanas.spec.ts` se vieron fallar contra el `src`
  de `HEAD` (restaurado después, sin `git stash`).
- Sin dependencias nuevas (`package.json` y lockfiles sin diff), sin commits ni staging, sin `vite build` ni `pnpm` en la
  VR, `grafo-tareas.api` sin tocar.
- Inestable, no de esta FASE: `grafo.test.ts` «una página (FASE 15) ocupa la media pantalla…» tarda ~5 s contra un
  límite de 5 s y con la máquina cargada se pasa; en una copia de `HEAD` dio 4,8 s (pasa) y 5,4 s (falla). Las dos últimas
  corridas completas, verdes.

**Desvíos del plan y por qué**
1. «Sin espacio, cae al primero con aviso» (Tarea 2): el aviso sale solo cuando el espacio pedido **ya no existe**; sin
   espacio pedido (primera vez, URL sin `?espacio=`) se ve el primero **sin aviso**, como dice D1. Igual en la web.
2. Pedir un proyecto en un espacio sin fila (0 o 1 vigente) da el espacio entero **sin aviso**, exista o no ese proyecto:
   no hay nada que elegir. Con fila, un proyecto que no existe cae al primero con aviso.
3. Web, «+» de proyecto: con 0 o 1 proyecto la fila de pestañas no se muestra, pero el «+» de proyecto sí (solo, sin
   `tablist`): sin él no se podría crear el segundo, que D2 da por posible.
4. Web, espacios que no se pueden leer: antes caía a «Todo»; ahora `useAlcance` devuelve `fallo` y el tablero dice «No se
   pudo leer la API» (sin mezclar mundos). El aviso `AVISO_ESPACIOS_NO_LEIDOS` ya no nombra «Todo». En la VR, lo mismo
   con `fallo` en `useAlcanceVr` → `useMapaApi` da error.
5. Fuera de los archivos del plan: `hoy-puedo.tsx` y `bloqueos.tsx` esperan a que el alcance se resuelva
   (`enabled: !cargando`); sin eso, al entrar sin `?espacio=` pedían primero todo mezclado. `tablero.tsx` suma el caso
   `fallo`.
6. e2e que cambiaron por D1 (no afirmaban «Todo» de alcance, pero dependían de él): `navegacion.spec.ts` acepta el
   `?espacio=` que ahora lleva siempre la barra; `tablero-roles.spec.ts` simula `GET /espacios` y sus proyectos (el tablero
   espera a saber el espacio) y la ruta de etapas pasa a `**/api/v1/etapas*` (ahora va con `?espacio=`).
7. VR, la regla en una sola fuente: `filtrosDelEspacio` + `filtroVigente` en `lib/filtro.ts`; el hook `useFiltroVr` los
   reparte a los dedos (`App.tsx`), al botón B (`FiltroConControl`, `alternarFiltro(filtros)`), a la leyenda y a `Grafo`
   (que ahora recibe `filtro` por prop: un filtro puesto que el espacio no tiene no se aplica y vuelve al volver a SIGSA).
8. VR, la leyenda sin método sale de `lib/leyenda.ts` (`leyendaDeTipos`, con test; ahí viven `ItemLeyenda` y `CERRADA`) y
   el color de cada tipo de `colorDeTipo` en `colores.ts`, que comparte con `colorDe` la regla del tipo (`colorDelTipo`).
   Los tipos del espacio pasaron de `useMapaApi` a `useAlcanceVr`.
9. Web: `NOMBRE_PROYECTO_GENERAL` se borró (D6 ya no busca «General» por nombre: el único vigente). VR: `TEXTO_TODO` y
   `TEXTO_TODO_EL_ESPACIO` borrados; web: `NOMBRE_TODO` y `NOMBRE_TODO_EL_ESPACIO` borrados.

**Para saber, no tocado:** en un espacio sin método con ciclo (Mis proyectos), el filtro 4 deja casi nada: la página
sintética (`paginaUnica`) trae `frenan: []`, así que solo quedan la HU y lo «para decir». La API no calcula `frenan` fuera
del método; arreglarlo pide API.

**Archivos a revisar, en orden de importancia**
1. `grafo-tareas.vr/src/lib/alcance.ts` (20-102): `vigentesPorOrden`, `proyectosConFila`, `resolverEspacio`,
   `resolverAlcance`; y `src/escena/useAlcanceVr.ts` (entero): las dos etapas (espacio → sus proyectos), `verificado`,
   `fallo`, `tipos`.
2. `grafo-tareas.web/src/lib/alcance/use-alcance.ts` (25-68) y `alcance.ts` (48-111): la misma regla en la web, `cargando`
   y `fallo`.
3. `grafo-tareas.vr/src/lib/filtro.ts` (17-104): `filtrosDelEspacio`, `filtroVigente`, `filtroAlMostrar` y
   `siguienteFiltro` con los filtros del espacio; `src/escena/useFiltroVr.ts`.
4. `grafo-tareas.vr/src/escena/BarraSuperior.tsx` (156-224): la leyenda con y sin método; `src/lib/leyenda.ts`;
   `src/lib/colores.ts` (20-65).
5. `grafo-tareas.web/src/components/pestanas-alcance.tsx` (178-237): sin «Todo», fila de proyectos con dos o más, el «+».
6. `grafo-tareas.vr/src/App.tsx` (190-250): el filtro vigente a `Grafo` y los dedos; `src/escena/FiltroConControl.tsx`;
   `src/escena/useMapaApi.ts` (103-158, 290); `src/lib/filas-de-alcance.ts` (36-51); `src/escena/BarraAlcance.tsx`.
7. `grafo-tareas.web/src/lib/alcance/destino-de-creacion.ts`; `src/app/tablero.tsx` (79-90); `src/app/hoy/hoy-puedo.tsx`;
   `src/app/bloqueos/bloqueos.tsx`.
8. Tests y e2e: `grafo-tareas.web/e2e/pestanas.spec.ts`, `navegacion.spec.ts`, `tablero-roles.spec.ts`; las constantes
   de `grafo-tareas.vr/src/lib/constants/alcance.ts` y `grafo-tareas.web/src/lib/constants/index.ts` (~110-115).

