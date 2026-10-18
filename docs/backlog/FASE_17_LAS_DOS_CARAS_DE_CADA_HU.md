# FASE 17: LAS DOS CARAS DE CADA HU (EL TRABAJO Y EL PLAN)

**Destraba**: que Freddy vea en el visor, por separado, lo que **está haciendo** de una HU (TRABAJO) y lo que **intuyó que había
que hacer** (las piezas de «🚀 Draft trabajo»), sin que el plan se mezcle con lo real. Es la base para, más adelante, resincronizar
plan ↔ real y encontrar brechas nuevas
**Listo para PR**: no · aprobada por Freddy 2026-10-18 («dale, comienza»); api `05d7887` pusheada y **desplegada** (migración
aplicada, con respaldo `grafo-2026-10-18_0233.dump` antes; Freddy: «go»); api `473897e` (mergeada) y `0dbfbb9` (trámites, FASE 15 t3)
desplegadas; Freddy lo vio en el visor el 2026-10-18 (dos caras, dedos 1-3, sin recalibrar); vr + bin + refs en Changes
**Prioridad**: Alta — la VR es lo que Freddy quiere ver
**Dependencias**: FASE 15 (las páginas por HU y el gesto de la pelota), FASE 16 (la bitácora: mover de cara es una edición)
**Fuente**: Freddy, 2026-10-18: «cada HU es como un libro… podría tener dos páginas. Una que es como las tareas, como lo real, y la
otra… lo que intuimos que íbamos a hacer». Al pasar una pieza a TRABAJO «tiene que desaparecer» del plan. Moverla «probablemente
voy a hacer en la aplicación web» (en Todoist era clic derecho → «Mover a»); en la VR, más adelante

> **Regla de esta FASE (la de la FASE 15):** qué es plan y qué es real, y qué va en cada cara, lo decide la **API**. La VR pide la
> página y la dibuja; lo único que agrega es el gesto para dar vuelta la hoja.

## Lo medido (2026-10-18, producción)

- «🚀 Draft trabajo» (Todoist `6P4h8Wp2pW59Fq2x`) tiene **7 tarjetas abiertas**, las 7 de la HU 20379, en los carriles A · Bandeja,
  B · Acceso y KPIs y C · Recepción. Las arman `/flow:brechas` + `/flow:pbi:repartir`
- Las 7 ya están en el grafo y hoy se ven **mezcladas con lo real** en la página de la HU 20379 (57 nodos)
- **El grafo no sabe de qué proyecto vino cada tarjeta:** `externoOrigen` es `todoist` para las dos (150 nodos). La etiqueta `pieza`
  hoy marca justo esas 7, pero sale de la cabecera de la descripción (`traducir.ts:63`), y una pieza que pasa a TRABAJO sigue colgando
  de su HU con esa cabecera (`traducir.ts:251`, R4): no distingue plan de real
- Solo **1 conexión cruza** de una cara a la otra: «[26309] Notificación al confirmar la recepción» (en el Draft) PERTENECE_A la
  «FASE 18 · Recepcionado Con Observación» (real)

## Understand

- [x] Entendimiento — 2026-10-18: pedido de Freddy (arriba) y lo medido

## Tareas

### Tarea 1: cada nodo sabe de qué cara es (API + importador)
- [x] 2026-10-18, en Changes: todo lo de abajo. Migración `20261018020000_cara` aplicada en las bases locales (dev y `_test`;
  `migrate diff --exit-code` = 0); en producción, **no**. Rojo probado: sin la regla que respeta lo movido, el e2e falla en la
  línea de la tarjeta movida. Local, contra Todoist: `--cara PLAN --seco` → 7 tareas, y después 7 TAREA en PLAN
- [x] Campo `Nodo.cara` (enum `Cara { REAL, PLAN }`, NOT NULL, default `REAL`). **Migración**: `ADD COLUMN` con default, sin
  backfill (todo lo de hoy queda REAL hasta reimportar el Draft). Se aplica en producción **con el «sí» de Freddy**, como toda migración
- [x] El importador de Todoist recibe la cara: `--cara PLAN` en `cli.ts`. Solo las **TAREAS** del proyecto la toman; lo que sintetiza
  (HU, carriles, ramas, FASE, personas) es compartido y queda REAL. `bin/importar-en-produccion todoist --proyecto <id>` pasa
  `--cara PLAN` solo cuando el id es el de `todoist.plan` en `refs.yaml` (nuevo: `todoist: { trabajo: 6VhFQg6v45qcJHPc, plan:
  6P4h8Wp2pW59Fq2x }`), para que no dependa de acordarse del flag
- [x] Mover de cara = editar: `cara` entra a `CAMPOS_EDITABLES` (`pulido/diferencias.ts`) y a `UpdateNodoDto`; el `PATCH /nodos/:id`
  lo anota en la bitácora y el importador lo respeta (FASE 16). Así la PWA podrá «Mover a» sin cambiar la API. `NodoResponseDto.cara`
- [x] e2e: importar el Draft → sus tareas PLAN; la misma tarjeta importada después desde TRABAJO → REAL (se movió en Todoist);
  movida con `PATCH` → la reimportación no la pisa

### Tarea 2: las páginas tienen dos caras (API)
- [x] 2026-10-18, en Changes: `PaginaDto` suma `libro` (el id de la página real: la VR agrupa sin calcular) y `cara`. La cara real
  recorre el árbol sin entrar a lo del plan (`arbolDe` con filtro); la plan es la HU + sus piezas de donde cuelguen. Unit 4 nuevos
  (rojo probado quitando el filtro) + e2e. API: unit 108 · e2e 51 · tsc 0 · lint 0; `openapi.json` regenerado
- [x] `calcularPaginas`: cada HU da su página **real** (id = el de la HU, como hoy) y, si tiene algo en el plan, su página **plan**
  (id `<hu>:plan`), justo después. `PaginaDto` suma `cara`. La real es la regla de hoy **sin** los nodos PLAN; la plan es la HU +
  sus nodos PLAN (lo que cuelga de una pieza del plan va con ella) + lo que eso necesita, a un salto (`conLoQueNecesita`, sin cambios).
  `abiertas` por cara. Una tarjeta del plan sin HU va a «Sin HU · plan»
- [x] Unit (`calcular-paginas.spec.ts`) + e2e (`paginas.e2e-spec.ts`): una pieza PLAN no está en la real; su cara plan la trae con la
  HU; una HU sin plan no tiene cara plan; el bloqueador de una pieza cruza de cara (la regla del salto, como entre HU)

### Tarea 3: la VR muestra una cara a la vez
- [x] 2026-10-18, en Changes: `librosDe` / `caraVisible` / `otraCara` (puros, `lib/paginas.ts`, tests con rojo probado);
  `estado-vr` guarda `libro` y `cara` (`cambiarLibro`, `irALibro`, `verCara`). Probado en headless contra la API local con el Draft
  importado: la barra dice «HU 20379 · Sin HU · plan · 7»; tocar «plan · 7» muestra la HU con sus 7 piezas, por color de carril
- [x] 2026-10-18, tick sin humano: el e2e de Playwright de la VR (`e2e/grafo-api.spec.ts`) fallaba **desde la FASE 15** (`876356b`
  hizo obligatorio `GET /derivado/paginas` y el test no lo simulaba). Ahora lo simula con dos caras y comprueba que se guarda solo lo
  real (`a`, `b`), no el plan (`p`): 3/3, y rojo probado abriendo el plan primero (el PUT trajo `p`). Corrido en el puerto 4180 con
  una config temporal: el 4173 es el del visor. **Cuidado:** `vite build` reescribe `dist/`, que es lo que sirve el visor; se restauró
  el build de `HEAD` contra producción (`index-LbGrmXy_.js`, el mismo de antes) desde un `git archive`
- [x] Girar la pelota y X / Y siguen cambiando de **HU**, y siempre caen en la cara **real** («TRABAJO va primero»). `estado-vr` suma
  `voltear()`: la otra cara de la misma HU, si tiene
- [x] 2026-10-18, Freddy en el visor: «esa cuarta tab se me hace horrible» → sin pestaña «plan · N». La HU con plan lleva la
  **esquina de su pestaña doblada** (ámbar); vista por el plan, la pestaña se pone ámbar y dice «plan N»; tocar la pestaña de la HU
  que se ve da vuelta la hoja. El gesto de la mano abierta le funcionó a la primera
- [x] 2026-10-18, bug que destapó entrar por la HU 20379: `<Instances>` de drei arma sus buffers una vez con el `limit` del primer
  render; con el tamaño de la página como límite, pasar de 50 a 98 nodos dejaba las esferas de más pegadas a la cabeza (HU 19565:
  sin esferas, 20 FPS). Capacidad = el tope de la API (`LIMITE_GRAFO`). Reproducido en headless (antes / después) y en el visor:
  **68 FPS** con las 98 esferas. Venía de la FASE 15; no se veía porque se entraba por la HU más grande
- [x] 2026-10-18, Freddy: la leyenda «va por página» → `ramasDePagina` (lo que la página PERTENECE_A); medido antes: 35 nodos
  llevan color de rama y **0** están unidos por una línea a otro de su color, así que el color es la única huella de esas ramas en
  la VR (no se cortan). Y girar la pelota solo cuenta con la **mano levantada** (`esManoAlzada`: la muñeca ≤ 0,45 m bajo los ojos;
  Freddy: con la mano abajo «va a parecer que siempre estoy tratando de cambiar de HU»); la altura relativa va al búfer
  `?depurar` para calibrar. VR 94 tests, rojos probados. En el visor: `index-DsYr_rPg.js`
- [x] Fila de arriba: una pestaña por HU (no por cara); la HU activa con plan muestra al lado `plan · N`, que también se toca con el
  rayo para voltear. En la cara plan, la pestaña dice `plan` resaltado: se sabe en qué cara uno está
- [x] 2026-10-18, producción: Draft reimportado como plan (seco: 7 actualizados, 0 nuevos; real igual). Páginas: HU 20379 real
  57 → 50 nodos (abiertas 21 → 14) y su plan, 8 (la HU + 7); 7 de 7 piezas en el plan y 0 en lo real. Las dos caras re-acomodadas
  desde un Chrome headless contra producción (`?pagina=1&reordenar`, PUT de 50 y de 7). VR `index-a4lo3TIZ.js` servida al visor
- [x] Cada cara guarda su acomodo (C2, `hogares` por id de página: ya funciona con ids distintos). Al desplegar, re-acomodar las dos
  caras de la HU 20379 (`?reordenar`): las 7 piezas hoy guardan la posición de la página real

### Tarea 4: dar vuelta la hoja con la mano
- [x] 2026-10-18, en Changes (escrita por un agente Fable a pedido de Freddy, revisada e integrada): detector puro (7 tests, rojo
  probado aceptando bajadas), `esManoAbierta` en `pose-mano.ts`, `GestoVoltear` (barrita verde a la derecha del arco de la pelota) y
  `VoltearConControl`. La lectura de dedos de los dos gestos quedó en `escena/mano-xr.ts` (no duplicada). VR: tsc 0 · lint 0 ·
  91 tests
- [x] `lib/gesto-voltear.ts` (puro, con tests como `gesto-pelota.ts`): **mano izquierda abierta que sube rápido** (la palma ≥ 20 cm
  en ≤ 0,4 s; números a calibrar) → `voltear`. Una pausa después, para que un gesto largo sea una sola vuelta. Abierta = la pose que
  el gesto de la pelota ya ignora (curvatura 0,00–0,01 medida en Freddy), así que no se pisan
- [x] `escena/GestoVoltear.tsx` lee las articulaciones de la mano izquierda (lo mismo que `GestoPelota.tsx`) y entra al búfer
  `?depurar`. Con control: apretar el stick izquierdo (no se usa para nada más)
- [ ] Calibración con Freddy en el visor (`?depurar`): 5 vueltas a propósito → 5; un minuto usando la VR normal → 0 vueltas sin querer

### Tarea 6: lo mergeado se ve (el anillo) — pedido de Freddy 2026-10-18
- [x] Decisión de Freddy: «mergeado» es **parte del flujo y se anota en la FASE**; lo tilda él con `/flow:tildar <n> mergeado`
  (ni Azure, ni git, ni `documentar`, que a veces corre con el PR solo abierto). Método: etapa `mergeado` en `~/bin/fase-tildar`
  y `/flow:tildar`; casilla `- [ ] Mergeado` en `## QA` de la plantilla (`new-concept`) y de las plantillas por rol con PR;
  columna «mergeado» en `fases.html` y `calidad.html` del Laboratorio
- [x] Pasada única en el Laboratorio: 35 FASE → las 18 terminadas (444, merge probado por URL commit) con `- [x] Mergeado`, las
  17 abiertas con `- [ ] Mergeado` (las tilda Freddy); modos respetados, idempotente. Contrastado contra Azure (solo lectura):
  32 mergeadas, 3 no (18 pausada, 36 rama dummy, 37 frenada)
- [x] api `473897e` desplegada: `importar:fases` lee la casilla → etiqueta `mergeada` en el nodo FASE (unit 110 · e2e 51, rojo
  probado). Producción: 18 FASE con la etiqueta. VR: `AnillosMergeados` (torus instanciado, de frente al usuario, sin rayo;
  escrito por un agente Fable y revisado), VR 104 tests. Headless contra producción: los 18 anillos en la HU 19565
- [x] 2026-10-18, Freddy en el visor: «un círculo gigantesco que molesta muchísimo» → el anillo se cambió por un **punto verde
  claro arriba a la derecha de la esfera** (`MarcasMergeadas`, `marcaDe` puro con tests y rojo probado) y «punto = mergeada» en la
  leyenda. Freddy tildó las 14 abiertas mergeadas: 32 FASE con la marca en producción. En el visor: `index-B2ma3I_d.js`, 68 FPS

### Tarea 7: el filtro «pendiente» con los dedos de la mano derecha — idea de Freddy 2026-10-18
- [x] Marcar lo mergeado sobre el nodo no funcionó: el anillo «molesta muchísimo», el punto obliga a «buscar una aguja en un
  pajar» y un tenue a medias «no se logra diferenciar». Freddy: un **filtro** que se elige mostrando dedos con la mano derecha
- [x] `lib/filtro.ts` (puro): se cuenta de menor a mayor — **1 = todo** (por defecto), **2 = pendiente**; 3-5 libres. «Pendiente»
  ilumina lo que ni se mergeó ni se cerró y apaga lo demás **con el contraste de una selección** (la misma capa `iluminados` de
  `Grafo.tsx`: esferas, textos y líneas); una selección manda sobre el filtro. Sin filtro no se apaga nada
- [x] Detector de dedos (`lib/conteo-dedos.ts` + `GestoNumero.tsx`, agente Fable, revisado): mano derecha alzada, el número
  sostenido 0,6 s, una vez por número; búfer `?depurar` en `window.__gestoNumero`. Botón B del control derecho alterna;
  `?filtro=pendiente` abre con el filtro puesto; la leyenda dice «filtro 2 · pendiente (1 = todo)». VR 111 tests, rojos probados.
  Headless contra producción: lo resuelto se hunde, quedan encendidas la FASE 36 y 37, las dudas y lo abierto
- [x] 2026-10-18, Freddy en el visor: (a) **todos** los gestos con la mano a la altura del **hombro** (`esManoAlzada`: 0,45 → 0,30 m
  bajo los ojos; dar vuelta la hoja no lo pedía); (b) con el filtro, el **hilo** sigue encendido si una de sus puntas está
  pendiente (`hiloEncendido`): «aunque se opaque un nodo… no significa que la dependencia haya desaparecido»; con una selección,
  la regla de siempre; (c) cada número es una **forma** de mano, la de Freddy (`numeroDeLaMano`): 1 índice · 2 índice y medio ·
  3 medio, anular y meñique · 4 los cuatro · 5 los cinco; el pulgar solo decide entre 4 y 5. Las hijas que se apagan con el
  filtro son las CERRADAS (26 de 34 en la HU 20379; 8 son las FASE mergeadas), no por su padre. VR 115 tests, rojos probados
- [x] 2026-10-18, Freddy en el visor («realmente siento que está muy maravilloso»): el hilo HU → FASE 19 brillaba aunque debajo
  todo estaba cerrado. Regla nueva del filtro 2 (`hilosDelFiltro`, no un filtro 3): un hilo de pertenencia brilla si debajo de
  la hija queda algo pendiente; uno de dependencia, si sus dos puntas siguen pendientes. VR 116 tests, rojo probado. En el
  visor: `index-BCFSXTGn.js`. Pendiente de su «sí»: descartar en el grafo las tarjetas manuales «falta URL commit» que duplican
  el trámite automático (15 tarjetas vs 5 trámites; la de la FASE 33 dice que faltan evidencias que ya están), y nombrar 🔵🟢🟠🟣
- [x] 2026-10-18, Freddy en el visor con el build de la última vista («es maravilloso… al fin tengo una forma de comprender»):
  los dedos 1 y 2 le funcionaron a la primera, y dar vuelta la hoja también; no pidió recalibrar nada. Lo que no entendía
  (verificado contra la API antes de contestar): el 2 apaga lo CERRADO y las FASE mergeadas (no solo mergeado); la pieza 1.3 se
  apaga porque está CERRADA (la cerré yo con su «sí», FASE 16 §Verificación), nada es automático; la **pelota verde** en la FASE 18
  es la pieza del Draft «[26309] Notificación…» del carril 🟢 Recepción, la única que cruza de cara; las 12 que se oscurecen en
  «Sin HU» son las CERRADAS (11 archivadas el 06-10 + la del URL commit de la FASE 19); las 6 dudas rojas de la 19565 vienen de
  `Tareas/<task>/entendimiento.md` §ABIERTO y siguen abiertas porque nadie las cerró ahí (revisión abajo)
- [x] 2026-10-18, Freddy: los «falta URL commit / Evidencias / wiki» son «más un estorbo y carga cognitiva que datos valiosos»
  → **dedo 3 = pendiente sin trámites** (FASE 15 tarea 3 cerrada con esto): la API marca esas tarjetas con `complemento:tramite`
  (`PATRON_TRAMITE` en el importador de Todoist, solo si el catálogo del área tiene el complemento; medido 12 de 144 títulos, 0
  falsos — «wiki» sola no, por las retros del 01-oct) y la VR las apaga además de lo resuelto (`encendidosPor`, `TEXTO_DEL_FILTRO`,
  `siguienteFiltro`: el botón B recorre 1 → 2 → 3). API unit 23 (importador) · tsc 0; VR 122 tests · tsc 0 · lint 0. Build
  `index-XwwoaPKg.js` servido; **falta cargarlo en el visor** (dormido) y desplegar la API + reimportar TRABAJO para que las 10
  manuales lleven la etiqueta (los 5 trámites automáticos ya la tienen en producción)
- [ ] Freddy lo prueba y se calibran los umbrales (`CURVATURA_ESTIRADO_MAXIMA`, el del pulgar, `SOSTENER_S`, el del hombro)

### Revisión: las 6 dudas abiertas de la HU 19565 (2026-10-18, agente Fable de solo lectura; pedido de Freddy: «sí, revísalo»)

Viven en `Laboratorio/Tareas/<task>/entendimiento.md` §ABIERTO (no en las FASE; carpeta fuera de git). Cerrar = editar ahí, con
el «sí» de Freddy. Veredictos con cita (Azure solo GET, reuniones, FASE):

1. **24690 · A1 lab destino vs análisis derivados** → CONTESTADA: Carabantes, Azure 24852 (28-09) + reunión 29-09
   (`docs/reuniones/reunion-2026-09-29-tomas-nicolas.md:46-60`): la actividad no se ofrece si el lab no la hace; el 422 queda de red.
2. **24690 · A2 qué es un «análisis opcional»** → CONTESTADA por reencuadre (30-09/01-10): un parámetro que se agrega dentro de los
   5 análisis, no un 6º (`FASE_15:156-163` N1, `FASE_16:17-19`; 25180/25182 mergeadas).
3. **24852 · rastro de tipo de muestra (Q4)** → SIGUE ABIERTA: negocio dijo que no va (Carabantes 28-09), pero nadie creó la task
   para borrarlo (`docs/onboarding/propuestas.md:21`, a Fabián desde el 29-09).
4. **24852 · «Cerrados el 29-09…»** → no es duda: nota de cierre bajo el encabezado equivocado (`FASE_7:3,195-203,247-248`).
5. **24972 · Q9 y Q10** → a medias: Q9 CONTESTADA (sí hay precarga, la unión; ADR `2026-09-30-mezcla-con-grupo-padre…`, Azure
   25094); Q10 (microorganismos en mezclas) nunca se preguntó: dueño Carabantes.
6. **24973 · para qué lo quiere el front** → CONTESTADA: gbaeza, Azure 24551 (28-09): `numero` es el id estable de la categoría.

- [x] 2026-10-18 tarde (Freddy: «valídalas tú y si te parecen obvias, toma las respuestas»; evidencia recomprobada por el
  orquestador contra Azure y los docs): 1, 2, 4 y 6 cerradas en sus `entendimiento.md` (sin viñeta, con su cita; respaldo previo en
  el tmp de la sesión) y la 5 partida (Q9 cerrada · Q10 abierta). `importar:fases` en seco y real: 2 abiertos leídos, **4 dudas
  cerradas** en producción, 1 actualizada. Quedan abiertas solo **Q4** (tipo de muestra: falta que Fabián cree la task) y **Q10**
  (microorganismos en mezclas: nunca se preguntó a Carabantes)
- [x] 2026-10-18 tarde, Freddy: Q4 «me suena al sprint anterior» y Q10 «supuestamente está resuelto». Cerradas las dos: **Q4 no es
  duda sino una propuesta a Fabián** (el negocio ya dijo que el tipo de muestra no va; borrarlo es una task que Fabián decide si entra;
  `propuestas.md:21` y la tarjeta del 29-sep, que sigue viva); **Q10 se resolvió por alcance**: filtrar la cascada de microorganismos
  al grupo es del front (`FASE_10` §Fuera de alcance), y si el front lo hace distinto lo ve QA. Reimportado: 2 cerradas; **ninguna
  duda de FASE queda abierta**

### Revisión: tarjetas de cierre que duplican el trámite (2026-10-18, tick sin humano, solo lectura; para decidir con Freddy)

15 tarjetas abiertas de Todoist hablan de «URL commit»; el grafo ya tiene el trámite automático de cada FASE (22, 5 abiertos), que
se cierra solo al tildar su cierre. Nada se descarta sin el «sí» de Freddy, una por una.

1. **Duplican un trámite abierto** (5): FASE 22, 32, 33, 34 y 35 — p. ej. «[25327] FASE 33 · … falta URL commit (Evidencias y
   wiki ya están)» = «FASE 33: falta URL commit».
2. **FASE sin trámite** (8): FASE 23, 24, 25, 26, 27, 28, 29 y 30 (Sonar, `**Tipo**: calidad`). Aquí la tarjeta es el único aviso:
   ¿se queda, o el cierre de las de calidad también debería dar trámite?
3. **Sin FASE** (2): «🟣 Cierres pendientes en Azure» (la madre, 17 hijas) y «Agregar URL commit… 7 de Sonar + 5 mergeadas después».

- [x] 2026-10-18, con el «sí» de Freddy: los 5 duplicados del grupo 1 **descartados** en el grafo con su motivo (contraste: 216 · 205
  iguales · 4 editados · 7 descartados); los del grupo 2 y 3 quedan. Las ramas 🔵🟢🟠🟣 **nombradas** (PATCH con motivo, en la
  bitácora) y el 🟡 **descartado** como rama (marca de estado «en curso»). Reimportación de TRABAJO en seco: 0 actualizados, los 7
  descartes respetados. La VR **abre en la última HU y cara vistas** (`lib/ultima-vista.ts`, VR 119 tests, rojo probado)

### Tarea 5: Freddy lo ve en el visor
- [x] 2026-10-18, Freddy en el visor: abrió la 20379, vio lo real, deslizó la mano hacia arriba y vio el Draft («ese es el mismo que
  está del otro lado… la versión que yo creé hace tiempo»); volvió. Después de reconciliar, la cara plan son 9 piezas por ronda

### Tarea 8: «Mover a» en la web (era «fuera de alcance»; Freddy contaba con él, 2026-10-18)
- [x] 2026-10-18, api `ff8bac1` + web `a20670e` desplegadas: `GET /nodos?cara=` (e2e: listar por cara, mover y volver, cara
  inválida → 400; rojo probado sacando el filtro del where). La web suma **Trabajo | Plan** arriba del tablero (el Plan ordenado por
  ronda) y **clic derecho → «Mover a Trabajo» / «Mover al Plan»** en cada tarjeta, más el mismo botón en el detalle (el teléfono no
  tiene clic derecho); las FASE no se mueven. `PATCH` de la cara con motivo «Movida desde la web: Plan → Trabajo» (bitácora; el
  importador lo respeta). Web: tsc 0 · lint 0 · 22 tests (4 de `mover-cara`, rojo probado). Probado en Chrome headless contra
  producción: Trabajo 100 tarjetas, Plan 10, el menú aparece (sin hacer clic: datos reales). La prueba destapó la 4.1b colgada
  (cerrada en Todoist, abierta en el grafo): cerrada con `PATCH` y motivo; el hueco del importador quedó como trampa en `CLAUDE.md`
- [x] 2026-10-18, Freddy en la web: el Plan salía todo en «Sin etapa» («¿no debería tener columnas como el Draft?») y el Trabajo
  sin filtro por HU («como las pestañas de la VR»), todo con la lógica en el back. api `b310b61` + web `fb8f1ab` desplegadas:
  `GET /derivado/plan?libro=` (una columna por carril —la RAMA con la etiqueta `carril`, que ahora pone el importador— con sus
  piezas abiertas en orden de ronda; `calcularTableroPlan`, puro) y `GET /nodos?libro=` (la misma regla de las páginas de la VR;
  la cara elige la página). La web: fila de HU (Todas · HU 19565 · HU 20379 · Sin HU) y el Plan por carriles con el borde de su
  color. API unit 116 · e2e 54; web 24 tests; rojos probados. Draft reimportado (2 carriles etiquetados). Probado en producción:
  HU 19565 → 38 tarjetas, Sin HU 59, Todas 100; Plan → A · Bandeja (3) y C · Recepción (6), igual que el Draft de Todoist.
  «Sin etapa» no es información chueca: 30 tarjetas de TRABAJO sin sección en Todoist (las notas sueltas de arriba) + 5 trámites
- [x] 2026-10-18, Q4 (tipo de muestra): Freddy no la quiere pedir todavía; es una corrección sin prioridad que no rompe nada.
  Rama **🧹 Normalización** creada en el grafo con la tarjeta del 29-sep colgada: el lugar de esas correcciones, visible en la
  web (Ramas) y en la VR (color), para cuando decida llevarlas a Fabián. La propuesta de etiquetas siguió en la FASE 18
- [x] 2026-10-18, Freddy: «revalidá en Azure y en develop si esas dudas se contestan; si no, son preguntas nuevas y van a la
  base». Revisadas las ~25 preguntas abiertas del reparto de la 20379 contra los 40 comentarios de Azure (la HU, sus 23 tasks,
  la 24433, la 20378 y la wiki 6738) y el develop de los 9 repos (sin cambios desde la foto de brechas). **Contestadas, no se
  cargan:** el laboratorio no filtra (Carabantes 15-10: «un usuario no puede pertenecer a más de un laboratorio»); Rechazar es de
  la 25015; los análisis sí tienen área (script `09_areas_funcionales.sql` de Thomas, `d785567`); los códigos OBSERVADA y
  EN_VERIFICACION_SECCION existen en la rama de la 25325; el solicitante entra al buscador (la HU lo pide en tres lugares); en el
  catálogo manda la planilla (FASE_18 D7). **Abiertas, cargadas en el grafo (16):** 8 dudas de negocio para Carabantes (Observar,
  «Volver» del modal, texto del aviso a analistas, «con Observaciones» ¿requiere acción?, 5 días hábiles o corridos y ¿cada noche?,
  quién confirma una recepción ajena, En Validación ¿de qué?, nombre y primer apellido ¿columna aparte?), 5 de código para Thomas
  (aprobar el esquema + orquestación + ¿`recepcion_muestra` sobra?, analistas de un área sin endpoint y catálogos que no calzan,
  nombre y apellido por separado, dónde corre el nocturno, **con qué id se guarda una persona**: D5 eligió el de Keycloak y el
  solicitante usa el de identidad), 2 supuestos y 1 dolor de código (comentario viejo en la migración de `laboratorio_analisis`).
  Cada una cuelga de su pieza o task y dice qué bloquea. Páginas: HU 20379 real 45 → 50 nodos, plan 12 → 25
- [x] 2026-10-18, Freddy en la web: «una columna que simplemente tiene nombre de fases: FASE 1, 2, 3, 22, 23… no entiendo la
  lógica». Eran **15 FASE duplicadas**: el importador del tablero sintetizaba «FASE n» pelada (sin etapa) cada vez que una tarjeta
  la nombraba, y volvía a crearla aunque se fusionara. api `d091edd` (`--fases-de`, la FASE se busca por externo en el
  orquestador y solo se crea si falta; unit con rojo probado) + `refs.yaml` `todoist.fases_de: laboratorio` + respaldo
  `grafo-2026-10-18_1721.dump` + `importar:fases --adoptar todoist` (15 adoptadas). Resultado: 35 FASE, todas del `.md` y con
  etapa; reimportar TRABAJO y el Draft en seco → 0 nuevos; «Sin etapa» 50 → 35 (0 FASE), «Sin HU» 72 → 57. Las 35 que quedan son
  notas de TRABAJO sin sección: las clasifica la FASE 18
- [x] 2026-10-18, Freddy revisando la HU 19565 («¿por qué tantas en Sin etapa y en ENTENDIMIENTO?»). Medido: su trabajo de
  producto está cerrado; lo abierto es Sonar (calidad) y papeleo. ENTENDIMIENTO tenía 10, de las que **8 eran trámites** («falta
  URL commit y Evidencias») puestos ahí solo por su sección de Todoist. Idea de Freddy: una columna **a la derecha de CERRADO**
  para lo que falta después de cerrar → api `9facc07`: etapa `TRÁMITES DE CIERRE` (después de CERRADO); un trámite va ahí sea
  cual sea su sección (importador de Todoist y trámites de las FASE; rojo probado en los dos). web `66c804c`: «Sin etapa» pasa a
  «Sin columna» y dice qué son. Reimportado: HU 19565 → TRÁMITES DE CIERRE 10 · ENTENDIMIENTO 2 · Sin columna 5. La 26750
  (Sonar api.solicitudes, hija de la 19565 en Azure, todavía sin FASE) estaba suelta: colgada de su HU y con la etiqueta
  `calidad` (PATCH con motivo); aparece en Calidad → ENTENDIMIENTO. Propuesto, sin hacer: (a) que el importador cuelgue toda
  tarjeta `[id]` de su HU por el padre en Azure, aunque no tenga FASE todavía; (b) que la tarjeta de una FASE mergeada no se
  muestre antes de APROBADO (hoy hay 7 en TESTEADO / LISTO PARA PR / Pull Request con su FASE ya mergeada: Todoist no se movió)

## Decisiones del agente (para revisar al leer)

Freddy pidió no preguntar: estas las tomó el agente. Cada una se cambia sin rehacer lo demás.

1. **La cara la decide el proyecto de Todoist, no el título ni la etiqueta `pieza`.** Es lo único que separa plan de real hoy (ver
   «Lo medido») y, después del corte de Todoist, queda como campo del grafo que se mueve desde la PWA
2. **Hacia arriba, no hacia abajo ni de lado.** Bajar la mano abierta es lo que uno hace para descansarla, y de lado es lo que hace al
   apuntar: los dos darían vuelta la hoja sin querer. Con dos caras, un solo sentido alcanza (va y vuelve)
3. **Girar la pelota cae siempre en lo real.** Lo real es lo que se trabaja; el plan se mira cuando uno lo busca
4. **El bloqueador cruza de cara.** Si una pieza del plan depende de algo real (o al revés), aparece como hoy aparece lo de otra HU:
   la regla del salto no cambia

## Fuera de alcance

- ~~**Mover del plan a lo real desde la PWA**~~: hecho en la tarea 8
- **Mover desde la VR**: cuando Freddy decida cómo (hoy no está definido y hacerlo mal obliga a rehacer)
- **Resincronizar plan ↔ real** (qué del plan ya se hizo, también lo que hizo un compañero, y las brechas nuevas): necesita las dos
  caras primero. Freddy: «sería horriblemente complejo» sin una herramienta para eso

## Criterios de Aceptación

- [x] 1 · Ninguna tarjeta del Draft aparece en la cara real de su HU (salvo como lo que necesita algo real, a un salto: hoy ninguna),
  y todas aparecen en su cara plan (e2e ✓ · producción 2026-10-18: 7 de 7 en el plan, 0 en lo real)
- [x] 2 · Mover una tarjeta de cara (en Todoist o con `PATCH`) la cambia de cara, y la reimportación no la devuelve (e2e)
- [ ] 3 · Freddy da vuelta la hoja en el visor sin vueltas sin querer (calibración: 5 de 5, y 0 en un minuto de uso)

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
