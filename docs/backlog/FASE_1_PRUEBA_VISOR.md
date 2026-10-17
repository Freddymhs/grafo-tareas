# FASE 1: PRUEBA EN EL VISOR — 500 NODOS ALREDEDOR, ¿RINDE Y SE LEE?

**Destraba**: la decisión del 3D (concepto § Stack, fila VR, y § Fases F1.0). Con esta FASE verde se escribe la API (FASE 2); en rojo, se revisa R3F contra el plan B (Godot 4) **antes** de escribir una línea de backend
**Listo para PR**: sí · 2026-10-16: FASE 1 VERDE — 72 FPS con 500 nodos en VR inmersiva (el tope del visor a 72 Hz), legible según Freddy. Ver `../decisions/DECISION_3D.md`
**Prioridad**: Alta — es la protección contra *"la IA dibujando horas sin resultado"* (concepto § Pareto 5)
**Dependencias**: ninguna. Solo `grafo-tareas.vr/` (nacido de `template-react-vite`); **datos sintéticos**, sin API ni Todoist
**Fuente**: `docs/_CONCEPTO.md` § Fases (F1.0), § Stack, § Por qué R3F, § Riesgos (legibilidad) · memoria `quest-3s-setup`

> **Alcance:** un repo (`grafo-tareas.vr`), una escena, datos falsos. Nada de lo que se escribe acá asume la forma de la API:
> el generador sintético produce `Nodo`/`Conexion` con los nombres del modelo de dominio, y en la FASE 4 se reemplaza por los
> hooks de Orval sin tocar la escena.

---

## Lo que ya existe — no rehacer

- `grafo-tareas.vr/`: Vite 8 + React 19 + TS 6 + Vitest (jsdom) + Playwright + ESLint + husky + `vite-plugin-pwa` + CI (`template-react-vite`).
- Visor: Quest 3S en Tailscale `quest-3s` (100.70.171.33). Por adb **siempre** `~/bin/quest-despierto -- <cmd>`; `quest-ver` captura lo que se ve.
- Versiones medidas el 2026-10-16 en npm: `three` 0.186 · `@react-three/fiber` 9.8 (peer `react >=19 <19.4`; hoy React 19.3.1) ·
  `@react-three/xr` 6.6 · `@react-three/drei` 10.7 · `d3-force-3d` 3.0 (**sin tipos**, ni propios ni `@types`) · `r3f-perf` 7.2.

## Las decisiones, y por qué

### D1 · WebXR exige contexto seguro: `localhost` por `adb reverse`, no HTTP por Tailscale
El Quest Browser solo ofrece `immersive-vr` en HTTPS o `localhost`. `quest-despierto -- adb reverse tcp:5173 tcp:5173` deja el
Vite del PC en `http://localhost:5173` **del visor**, con recarga en caliente y sin certificados. Con la VPN del trabajo el adb ya va
por Tailscale; si el relay es lento, el plan B es `tailscale serve` (HTTPS con el certificado de la tailnet).

### D2 · Nodos con `InstancedMesh`, aristas en UNA geometría
500 `<mesh>` sueltos son 500 draw calls: el visor no los sostiene a 72 Hz. Nodos = una `<Instances>` de drei (una draw call por
tipo de nodo, color por instancia); aristas = un solo `LineSegments` con un `BufferGeometry` de posiciones. La escena es declarativa
(R3F), pero la cantidad de objetos de three.js es fija y chica.

### D3 · Etiquetas solo cerca o seleccionadas
`<Text>` de drei (troika) por cada nodo no escala ni se lee. Se muestran las **N más cercanas a la cámara** (constante `ETIQUETAS_CERCANAS`) y
la del nodo seleccionado. Si parpadea, subir `framebufferScaleFactor` (reporte en Quest 3: 1.35; concepto § Riesgos).

### D4 · El layout se calcula una vez, fuera del render
`d3-force-3d` corre N ticks al cargar (función pura, en un Web Worker si pasa de ~200 ms) y devuelve `posicion {x,y,z}`; la escena
solo las lee. Es lo que en la FASE 4 se persiste en la API (C2). Sin tipos: un `src/lib/d3-force-3d.d.ts` declara **solo** lo que se usa.

### D5 · Datos sintéticos deterministas
Generador con semilla fija (PRNG propio, sin `Math.random`: regla React 19 `react-hooks/purity` y reproducibilidad) que imita lo medido
en Todoist: ~6 ramas de color, nodos en 1-2 ramas, ~1,5 conexiones por nodo, algunas PERSONA/DUDA que bloquean varias tareas.

## Understand

- [x] Entendimiento — no aplica: FASE técnica sin tarea de cliente; el entendimiento es `docs/_CONCEPTO.md` § Fases F1.0

## Tareas

### Tarea 1: dependencias 3D y limpieza de la plantilla

- Archivo: `grafo-tareas.vr/package.json`, `vite.config.ts`, `src/App.tsx`, `src/App.test.tsx`
- Qué hacer: `npm i three @react-three/fiber @react-three/xr @react-three/drei d3-force-3d` + `npm i -D @types/three`
  (pide confirmación: es instalador). Manifest de `VitePWA` con el nombre del proyecto. Sacar el contenido demo de `App`.
- [x] Hecha — 2026-10-16. Rangos con caret; manifest y `<title>` del proyecto; README del repo reescrito arriba
- [x] Gates verdes: `npm run type-check` · `npm run lint` · `npm run test:run` (12/12) · `build` · e2e con el Chrome del sistema

### Tarea 2: el modelo y el generador sintético

- Archivo: `src/lib/dominio.ts` (tipos `Nodo`, `Conexion`, enums `TipoNodo`, `TipoConexion` — los nombres del concepto § Modelo de dominio),
  `src/lib/sintetico.ts` (+ test)
- Qué hacer: `generarGrafo({ nodos, semilla })` puro. Constantes con nombre en `src/lib/constants/` (cantidad, ramas, densidad).
- [x] Hecha — 2026-10-16. PRNG sin estado `aleatorio(semilla, índice)` (`src/lib/aleatorio.ts`): sin `Math.random` ni generador mutable
- [x] Test: misma semilla → mismo grafo; 500 nodos; toda conexión apunta a nodos que existen; DEPENDE_DE sin ciclos

### Tarea 3: layout de fuerzas

- Archivo: `src/lib/layout.ts` (+ test), `src/lib/d3-force-3d.d.ts`
- Qué hacer: `calcularLayout(grafo, ticks)` → `Map<id, posicion>`. Medir cuánto tarda con 500 nodos; si > 200 ms, mover a Worker.
- [x] Hecha — 2026-10-16. **Medido en el PC: 100 nodos 176 ms · 300 → 604 ms · 500 → 1175 ms · 1000 → 2869 ms** → va en un Web Worker (`layout.worker.ts`). Burbuja libre de 1 m alrededor de los ojos: sin ella los hubs de rama caían en la cara
- [x] Test: posiciones finitas para todos los nodos, dentro de [1 m, 4 m]; dos corridas dan lo mismo

### Tarea 4: la escena y la entrada en VR

- Archivo: `src/escena/Grafo.tsx`, `src/escena/Nodos.tsx`, `src/escena/Aristas.tsx`, `src/escena/Etiquetas.tsx`, `src/App.tsx`
- Qué hacer: `<Canvas>` + `createXRStore()` de `@react-three/xr` + botón "Entrar en VR". Nodos por D2, aristas por D2, etiquetas por D3.
  Selección con el rayo del control: el nodo seleccionado muestra título y **qué lo bloquea** (sus `DEPENDE_DE`/`BLOQUEADA_POR` abiertas).
  FPS dentro del visor con `Medidor` (r3f-perf se descartó: es overlay HTML y en VR no se ve).
- [x] Hecha — 2026-10-16. Más: `Medidor` (FPS pegado a la vista, r3f-perf no se ve en VR, por eso no se usa) y `?nodos=`/`?semilla=`. Aristas en dos capas: PERTENECE_A tenue (es la mitad y el color ya dice la rama). El emulador IWER solo en desarrollo: con sus salas pesaba ~5,9 MB en el precache (7,2 MB → 1,4 MB)
- [x] Probado en el PC sin visor (Chrome headless con WebGL por software): 500 nodos dibujados, etiquetas cercanas, click → "Tarea 100 · ABIERTO / Libre: nada lo bloquea"
- [x] Probado en el PC con el emulador IWER entrando a VR — 2026-10-16, Chrome headless: escena + controles + rayos, 0 errores. Dos arreglos para llegar: (1) iwer 2.6 no pisa el `navigator.xr` nativo de Chrome sin `forceInstall` → `src/lib/emulador.ts` lo instala así, solo en dev; (2) devui traía su `three` 0.165 (`material.onBuild is not a function` cada frame, pantalla negra) → `overrides: { three: "$three" }`, una sola copia. `enterVR` que falla ahora se muestra en pantalla (`role=alert`) y pasa por `src/lib/registro.ts`

### Tarea 5: medir en el Quest 3S

- Qué hacer: **`bin/probar-en-visor --abrir`** (desde el orquestador): build de producción + `vite preview` + `adb reverse` envuelto en `quest-despierto` + abre `http://localhost:4173/?nodos=500` en el Quest Browser → Entrar en VR. `--nodos 100`/`300` para las otras medidas; `--dev` para iterar con recarga en caliente (no para medir: React en dev rinde menos).
  Anotar FPS (el `Medidor`, pegado a la vista abajo a la izquierda) con 100, 300 y 500 nodos (`?nodos=`); capturar con `quest-ver`. Probar legibilidad: ¿se lee el título a 1 m? ¿se distingue la rama por color?
- [x] Hecha — 2026-10-16, con Freddy puesto: build de producción por `bin/probar-en-visor`, abierto por adb en el Quest Browser
- [x] Resultado escrito en `docs/decisions/DECISION_3D.md` (sigue R3F, o plan B) con los números

## Criterios de Aceptación

- [x] 1 · — 72 FPS (71-72) en VR inmersiva, capturado con `quest-ver` · 500 nodos + sus aristas a **≥ 72 FPS sostenidos** en el Quest 3S (medido, no estimado)
- [x] 2 · — Freddy: "lo veo todo sin problema"; orden visual queda para después · El título del nodo seleccionado y de los cercanos se lee sin esfuerzo; las ramas se distinguen por color
- [x] 3 · — probado en el PC (click → título + "Libre/Bloqueado por") y aceptado como MVP en el visor · Seleccionar un nodo muestra qué lo bloquea
- [x] 4 · — 13/13 tests, tsc 0, lint 0, e2e verde · `type-check`, `lint` y `test:run` en verde; ningún `let`, ningún `any` sin comentario, ningún `Math.random`/`Date.now` en hooks
- [x] 5 · — DECISION_3D.md: sigue R3F, no hace falta el plan B · `DECISION_3D.md` escrita: si 1 o 2 fallan, propone el plan B (Godot 4) y **se para** antes de la FASE 2

## QA

- [x] Colección — no aplica: no hay API en esta FASE
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
