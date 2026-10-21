# FASE 21: ENCONTRAR CUALQUIER TARJETA Y VER BLOQUEOS QUE DICEN LA VERDAD

**Destraba**: encontrar una tarjeta o una duda escribiendo, sin recorrer columnas. Que lo ya mergeado deje de verse como
bloqueo (la 25325 aparecía frenada por la 26309, mergeada el 20-10). Que una dependencia que un `.md` dejó de declarar no
quede para siempre en el grafo.
**Estado**: sin rama
**Azure**: no aplica (tracker: none)
**Tipo**: producto
**Dependencias**: ninguna
**Fuente**: Freddy, 21-10: «¿por qué no existe un buscador dentro de esta zona?… para poder encontrar tarjetas más
fácilmente» · FASE 18 del Laboratorio, «**Dependencias**: FASE 38 mergeada» · la propuesta A.1 a la sesión control (20-10) ·
Freddy, 21-10, sobre Herdr: «no quiero agarrarlo de header y que mueva mis grafos ni para un lado ni para el otro»

## El hueco, medido

Medido el 21-10, antes de los cambios:
- **El tablero de la web no tenía buscador.** La API ya buscaba en título y descripción (`?q=`), pero solo la usaba el
  «conectar» del detalle.
- **Una duda no se encontraba desde el tablero.** «Reportar issues de la plantilla Adonis… por Teams» era una duda, y el
  tablero solo pedía tareas y FASE.
- **Lo mergeado bloqueaba.** Solo contaba como cumplido lo CERRADO, y una FASE mergeada sigue ABIERTA hasta sus trámites:
  `GET /nodos/<FASE 18>/bloqueado` respondía `bloqueado: true, por: FASE 38`.
- **El importador nunca borra conexiones.** Una DEPENDE_DE que el `.md` corrigió quedaba al revés y armaba un ciclo con la
  nueva (FASE 38 → 18, 20-10; la sesión control la borró a mano).

## Las decisiones

### D1 · El buscador busca dentro de lo elegido y trae también las dudas — Freddy, 21-10 `[código]`

- **Qué busca:** título y descripción (`q`), desde 2 letras, dentro de la HU y el rol elegidos.
- **Dudas:** buscando, el tablero suma las dudas abiertas; sin búsqueda, sigue siendo el de siempre.
- **Lo cerrado:** no aparece, y el aviso lo dice.

### D2 · Depender de algo ya mergeado está cumplido — 21-10 `[código]`

- **La regla:** un DEPENDE_DE hacia algo mergeado ya no bloquea. Mergeado es la etiqueta `mergeada` (la lleva el nodo
  FASE) o estar en la columna APROBADO, que según `roles.yaml` es «mergeado: el PR entró a la base» (ahí deja el hook a la
  tarjeta `[<id>]`, sin etiqueta). Esperar respuesta o estar bloqueada por algo mergeado siguen frenando.
- **Dónde vive:** `dependenciaCumplida` (pura), con su espejo en Prisma, `BLOQUEA_AHORA`.
- **A qué aplica:** `/bloqueado`, «hoy puedo», el parte del día y lo que frena en cada página (el filtro 4).

### D3 · El importador informa las dependencias viejas; solo las borra si se le pide — 21-10 `[código]`

`dependenciasViejas` compara las DEPENDE_DE entre FASE del proyecto con lo que declaran los `.md`, y el resumen las lista
siempre. Se borran solo con `--podar`, porque una conexión hecha a mano en la web entre dos FASE tampoco está en un `.md`.

### D4 · Herdr nunca escribe en el grafo — Freddy, 21-10 `[negocio]`

El mismo día se probó y se sacó un `PUT /nodos/orden-del-dia`, que copiaba AHORA de Herdr como `hoy:<n>`, junto con su
lente «hoy» en la VR. Lo vio funcionar en el visor. Contrato: `docs/decisions/DECISION_TRES_MUNDOS_Y_DAILY.md`.

## Abierto

Ninguno.

## Understand

- [x] Entendimiento — los cuatro huecos medidos en producción el 21-10 (arriba)

## Tareas

### `grafo-tareas.web`
- [x] **Tarea 1** · `src/app/tablero.tsx` + `src/lib/grafo/busqueda.ts` — la caja «Buscar tarjetas…»; `textoDeBusqueda` es
  la regla de los dos buscadores (test rojo primero) · `a417ce2`
- [x] **Tarea 2** · buscando, el tablero trae también las dudas (`buscaDudas`, test rojo primero) · `c8eeda5`

### `grafo-tareas.api`
- [x] **Tarea 3** · `src/modules/derivado/dependencia-cumplida.ts`, `derivado.repository.ts` (`BLOQUEA_AHORA`) y
  `calcular-paginas.ts` — lo mergeado no bloquea (unitario y e2e rojos primero) · `284aa1d`. Con la 25325 mergeada
  apareció que la tarjeta [26998] seguía frenada por la tarjeta [25325], que está en APROBADO y no lleva la etiqueta;
  se suma la columna, y «sin columna» se pide explícito, porque el NULL de SQL rompía «hoy puedo» (3 e2e lo atraparon) ·
  `f8663af`
- [x] **Tarea 4** · `src/importadores/fases/dependencias-viejas.ts` y el importador — informa y, con `--podar`, borra
  (unitario y e2e rojos primero) · `dbb1692`; `bin/importar-en-produccion` pasa `--podar` · `3ab1128`
- [x] **Tarea 5** · el orden del día: `PUT /nodos/orden-del-dia` (`0d09b44`) y el lente «hoy» de la VR (`471e32b`,
  `e9172ff`), probados y sacados por D4 · `1cd8226` y `d592733`

## Criterios de Aceptación

- [x] 1 · con «Adonis», el tablero de producción muestra «1 con «Adonis» en el título o la descripción» y la duda
  (Playwright sobre la PWA, 21-10)
- [x] 2 · en producción, `GET /nodos/<FASE 18>/bloqueado` da `bloqueado: false`. Con la 25325 mergeada (21-10), la
  FASE 39, la FASE 41 y la tarjeta [26998] quedan libres
- [x] 3 · `importar-en-produccion fases … --seco` lista `dependenciasViejas` (hoy `[]`) y no borra nada sin `--podar`
- [x] 4 · en producción no queda ninguna ruta ni etiqueta que copie Herdr al grafo (`orden-del-dia` publicadas: 0;
  etiquetas `hoy:`: 0)

## Fuera de alcance

- Elegir el día desde el grafo mismo (en la web o en la VR): no se pidió.
- Borrar las dependencias viejas sin pedirlo.

## QA

- [x] Colección — no aplica (proyecto personal, sin Postman)
- [x] Auditoría — 2026-10-21: API 131 unit · 64 e2e; web 41 · tsc · eslint; VR 158; rojos probados en cada tarea
- [x] Listo para PR — 2026-10-21: commiteada y pusheada (commits arriba); grafo-tareas no usa PR
- [x] Mergeado — en `main` desde cada commit, desplegada en el Mac Mini (API y PWA 200)

## Cierre oficial en Azure

- [x] URL commit — no aplica (tracker: none)
- [x] Evidencias — no aplica (tracker: none)
- [x] Wiki actualizada — no aplica (tracker: none)
