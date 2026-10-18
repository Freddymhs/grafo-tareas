# FASE 15: LA PANTALLA CURVA Y LAS PÁGINAS (UNA HU A LA VEZ)

**Destraba**: que Freddy lea su trabajo en el visor sin que se vea «apilado» ni «desordenado» (2026-10-17, en el visor: «me recuerda
a Obsidian, pero en Obsidian se ve más segmentado, más ordenado»). Trabaja una HU a la vez: esa es la que tiene que ver
**Listo para PR**: no · api `47d3a99` (pusheada y desplegada) · vr `e8776fb` `d0eb364` `65a6fde` `876356b` (los tres primeros pusheados; `876356b`, las páginas, sin pushear) · el gesto, en Changes
**Prioridad**: Alta — la VR es lo que Freddy quiere ver
**Dependencias**: FASE 13 (el árbol), FASE 14 (moverse y leer)
**Fuente**: Freddy en el visor, 2026-10-17 · regla suya: **«la lógica no se construye en la VR, solamente se muestra»**

> **Regla de esta FASE:** qué hay en un libro, qué se filtra y qué es trámite lo decide la **API** (con sus tests). La VR pide y dibuja;
> lo único que calcula es geometría de presentación (dónde dibujar cada nodo).

## Lo medido

- **Lo apilado venía de la profundidad:** el layout de fuerzas en 3D ponía nodos unos detrás de otros. Obsidian dibuja en 2D.
- **Lo disperso venía de lo suelto:** en un layout de fuerzas, lo que no tiene conexiones sale despedido al borde y, como el más lejano
  fija la escala, encoge todo lo demás.
- **216 nodos en un solo grafo siguen desordenados aunque sea plano:** enrollados en 360° quedan estirados ~8:1 y las aristas largas
  cruzan la pantalla (captura headless 2026-10-17). Mostrar menos a la vez (un libro) es lo que hace Obsidian.
- **«Trámite» hoy no cubre lo que Freddy llama trámite:** 22 nodos llevan `complemento:tramite` (los «cierre oficial completo» de las
  FASE, 5 abiertos); las 20 tarjetas de Todoist «falta URL commit / Evidencias / wiki» **no** la llevan.

## Understand

- [x] Entendimiento — 2026-10-17: pedido de Freddy en el visor (leyenda, pantalla curva 360° a la altura de los ojos sin subir/bajar,
  filtro por los roles del tablero, libros por HU cambiados con la mano izquierda, ocultar trámites); medido arriba

## Tareas

### Tarea 1: la pantalla curva (VR, solo geometría)
- [x] Hecha — 2026-10-17, vr `e8776fb`: `calcularLayout` = fuerzas en 2D enrolladas en un cilindro de 3 m a la altura de los ojos
  (±1 m), sin profundidad; las sueltas en una grilla detrás ordenada por título; `ubicarFaltantes` sobre la misma pantalla; `?radio=`
  calibra al recalcular. VR 38/38 tests. Producción recalculada con `?reordenar` (las posiciones de la esfera quedan en el respaldo
  `grafo-2026-10-17_2236.dump`)
- [x] 2026-10-17, vr `d0eb364` + `65a6fde`: todas las etiquetas a la vista (`?etiquetas=`) y **cada nodo reserva la celda de su texto**:
  el acomodo corre en metros de la pantalla desenrollada con choque entre celdas (test: 172 textos pisados sin choque, ≤ 2 % con
  choque); la pertenencia a una rama tira poco (el color ya la dice). Freddy en el visor: «quedó increíblemente mejor»

### Tarea 2: las páginas en la API
- [x] Hecha — 2026-10-17, api `47d3a99`: `GET /derivado/paginas` (`calcularPaginas`, puro): una página por HU con su árbol por
  PERTENECE_A más lo que bloquea a lo suyo (un salto; y a quién espera una duda); las ramas no entran (son el color); «Sin HU» al final.
  Unit 7 + e2e. Desplegada: HU 19565 · 98 nodos (30 abiertas) · HU 20379 · 57 (21) · Sin HU · 53 (41). Filtros por rol y trámites:
  todavía no

### Tarea 3: qué es trámite (importador)
- [ ] Marcar como trámite las tarjetas de cierre («falta URL commit / Evidencias / wiki»). **Espera la pregunta 2**

### Tarea 4: la VR muestra una página
- [x] 2026-10-17, vr `876356b`: la página al frente (`aberturaPara`: 180°, más si no cabe, hasta 270°); cada página guarda su acomodo
  (C2), un nodo de dos páginas es de la primera (`hogares`); fila de arriba con pestañas (tareas abiertas, la activa en azul) y la
  leyenda de colores; X / Y del control izquierdo. Los colores se calculan sobre el grafo entero. Producción re-acomodada por página
- [ ] Freddy lo ve en el visor (estaba jugando: queda para cuando abra el navegador)

### Tarea 5: girar la pelota (gesto de Freddy)
- [ ] 2026-10-17, **en Changes** (vr, sin commitear, tick sin humano): `lib/gesto-pelota.ts` (puro: pose de sostener + giro ≥ 50° en
  ≤ 0,5 s, pausa de 0,6 s; tests 8, rojo probado quitando ventana y pausa) y `escena/GestoPelota.tsx` (mano izquierda por
  articulaciones, arco de progreso abajo al centro). **Falta calibrar con Freddy en el visor:** los umbrales son una primera estimación
- [x] Calibración 1 — 2026-10-17, con Freddy («me costó mucho cambiar una página»): 91 s grabados con `?depurar` (búfer
  `window.__gestoPelota` leído por CDP). Medido: sus giros son de 100° a 160° en < 0,5 s; la pose estaba activa solo el 38 % del tiempo
  (su mano curvada mide 0,16–0,18 m puntas→muñeca, el tope era 0,16; el pulgar roza el índice al girar = «pellizco»); la mano **vuelve**
  sola (+114° y −110° al segundo), así que con la regla vieja cada cambio se deshacía (10 cambios simulados, alternados). Y la causa de
  fondo: la sostiene **vertical**, y el ángulo muñeca→nudillos proyectado al plano es ruido. Cambios: giro real alrededor del eje vertical
  por la orientación de la muñeca (`lib/giro-vertical.ts`, con test de signo y de pose vertical), sin filtro de pose, umbral 70° en 0,4 s,
  el regreso bloqueado 1,2 s. VR 60/60
- [ ] Calibración 2 — en curso: los primeros 16 s de la segunda grabación dan 7 cambios (`+ + − − + + +`); falta que Freddy diga cuáles
  quiso hacer

### Tarea 7: más texto donde hay espacio
- [x] 2026-10-17, vr `6fc9b9b`: `lineasPara` — cada página elige 2, 3 o 4 líneas por etiqueta según su espacio;
  `medidasEtiqueta(lineas)` da texto, celda y letras (SSOT del acomodo y del dibujo). Test: con 4 líneas no se pisan textos. Producción
  re-acomodada por página. «Sin HU» (53 nodos) sube a 4 líneas; la HU 19565 (98) queda en 2 (ahí se lee apuntando)
- [ ] Freddy lo ve en el visor (se desconectó de adb: `offline`, probablemente dormido)

### Tarea 8: al seleccionar, iluminar la familia
- [x] 2026-10-17, api `640486d` (desplegada) + vr `6fc9b9b`: `GET /nodos/:id/familia` = el nodo, lo que cuelga de él (el mismo árbol
  de las páginas, `arbol.ts` compartido) y con qué se conecta directo; la VR ilumina eso (color y líneas) y hunde lo demás hacia el
  fondo. Unit 4 (rojo probado) + e2e. En producción: la familia de la HU 19565 son 90 nodos
- [ ] Freddy lo prueba en el visor

### Tarea 6: marcar lo mergeado
- [ ] Pedido de Freddy 2026-10-17: un botón en la fila de arriba que distinga lo ya mergeado (y ver qué le falta: URL commit, avisar a
  Thomas, compartir con el front). Qué es «mergeado» lo decide la API — **a confirmar con Freddy** (¿columna «Pull Request» / APROBADO?
  ¿«mergeado» en el título?)

## Preguntas para Freddy (abiertas)

1. **Trámites:** ¿el importador marca como trámite las tarjetas «falta URL commit / Evidencias / wiki», y la página las oculta de
   entrada con un botón para verlas?
2. **Mergeado (tarea 6):** ¿qué cuenta como mergeado? Freddy: «no hay un hook que lo detecte». Pista (2026-10-17): las subtareas de la tarjeta «🟣 Azure · lo hacés vos…» son justo lo mergeado sin cierre, y sus títulos lo dicen. Sin decidir

Cerradas 2026-10-17: el contenido de una página (HU + FASE + tarjetas + piezas + lo que las bloquea) y la página «Sin HU» («me agrada
todo eso»).

## Criterios de Aceptación

- [x] 1 · Sin profundidad: todo nodo a la misma distancia del usuario y en la banda de los ojos (test `grafo.test.ts`)
- [ ] 2 · Freddy abre un libro y lo lee sin que se vea apilado
- [x] 3 · Lo que decide el contenido de una página tiene e2e en la API (`paginas.e2e-spec.ts`); la VR no lo recalcula

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
