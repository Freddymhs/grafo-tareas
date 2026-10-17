# DECISIÓN — el 3D se queda en WebXR con React Three Fiber (FASE 1 verde)

**Fecha:** 2026-10-16 · **Decide:** Freddy, con la prueba en su Quest 3S · **Fuente:** `../backlog/FASE_1_PRUEBA_VISOR.md`

## Qué se probó

500 nodos sintéticos + 943 aristas alrededor del usuario, en el Quest Browser, sesión `immersive-vr`, build de
producción servido por `bin/probar-en-visor` (`vite preview` + `adb reverse`, `localhost` = contexto seguro).

## Lo medido

| | resultado |
|---|---|
| FPS en VR inmersiva, 500 nodos | **72** (71-72): el tope del visor, que corre a 72 Hz en modo trabajo (`quest-perfil`) |
| FPS en el panel 2D del navegador | 72 |
| Ramas por color | se distinguen (azul, naranja, morado, rosado, verde; personas blancas, dudas rojas) — captura `quest-ver` |
| Legibilidad y selección | "lo veo todo sin problema" (Freddy); orden y pulido visual quedan para después |
| Layout de 500 nodos en el PC | 1175 ms → va en un Web Worker; en el visor no congela la escena |

No se midió con 100 ni 300 nodos: con 500 ya está en el tope, menos nodos no aporta.

## Por qué sigue R3F y no el plan B (Godot 4)

El riesgo que la FASE 1 debía descartar —que WebXR no rinda o no se lea con cientos de nodos— no apareció: 500
nodos en una draw call (`<Instances>`) y las aristas en dos geometrías dejan al visor en su máximo. Seguir en
TypeScript + R3F mantiene un solo lenguaje en los tres repos y la escena declarativa que la IA edita sin romper
(concepto § Por qué R3F).

## Lo que queda abierto (no frena la FASE 2)

- Orden visual del grafo (agrupar por rama, distancia por relevancia): "lo veremos en el futuro" — Freddy.
- Medir de nuevo con datos reales (FASE 6, VR contra la API): el grafo real puede tener otra densidad que el sintético.
