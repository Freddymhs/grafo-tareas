# FASE 15: LA PANTALLA CURVA Y LOS LIBROS (UNA HU A LA VEZ)

**Destraba**: que Freddy lea su trabajo en el visor sin que se vea «apilado» ni «desordenado» (2026-10-17, en el visor: «me recuerda
a Obsidian, pero en Obsidian se ve más segmentado, más ordenado»). Trabaja una HU a la vez: esa es la que tiene que ver
**Listo para PR**: no · tarea 1 en vr `e8776fb` (commiteado, sin pushear); tareas 2-4 esperan las respuestas de abajo
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

### Tarea 2: los libros en la API
- [ ] `GET /libros` (uno por HU) y `GET /libros/:id` (su contenido), con filtros `rol=` (la regla del tablero) y ocultar trámites.
  **Espera las preguntas 1 y 3**

### Tarea 3: qué es trámite (importador)
- [ ] Marcar como trámite las tarjetas de cierre («falta URL commit / Evidencias / wiki»). **Espera la pregunta 2**

### Tarea 4: la VR muestra un libro
- [ ] El libro abierto al frente, plano; repisa de libros en la mano izquierda (gatillo o pellizco; deslizar, después); panel con
  leyenda, roles, ocultar trámites y volver al centro

## Preguntas para Freddy (abiertas)

1. **Qué entra en un libro:** la HU + sus FASE + las tarjetas de esas FASE + las piezas del Draft + las dudas que las bloquean. ¿Falta
   o sobra algo?
2. **Trámites:** ¿el importador marca como trámite las tarjetas «falta URL commit / Evidencias / wiki», y el libro las oculta de
   entrada con un botón para verlas?
3. **Lo que no es de ninguna HU** (notas, retros, onboarding 22204): ¿un libro «Sin HU», o no se muestra?

## Criterios de Aceptación

- [x] 1 · Sin profundidad: todo nodo a la misma distancia del usuario y en la banda de los ojos (test `grafo.test.ts`)
- [ ] 2 · Freddy abre un libro y lo lee sin que se vea apilado
- [ ] 3 · Lo que decide el contenido y los filtros tiene e2e en la API; la VR no lo recalcula

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
