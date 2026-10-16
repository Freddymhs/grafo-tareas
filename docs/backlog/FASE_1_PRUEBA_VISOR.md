# FASE 1: PRUEBA EN EL VISOR — 500 NODOS ALREDEDOR, ¿RINDE Y SE LEE?

**Destraba**: la decisión del 3D (concepto § Stack, fila VR, y § Fases F1.0). Con esta FASE verde se escribe la API (FASE 2); en rojo, se revisa R3F contra el plan B (Godot 4) **antes** de escribir una línea de backend
**Listo para PR**: no · FASE recién escrita (2026-10-16), sin código
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
- Qué hacer: `npm i three @react-three/fiber @react-three/xr @react-three/drei d3-force-3d` + `npm i -D @types/three r3f-perf`
  (pide confirmación: es instalador). Manifest de `VitePWA` con el nombre del proyecto. Sacar el contenido demo de `App`.
- [ ] Hecha
- [ ] Gates verdes: `npm run type-check` · `npm run lint` · `npm run test:run`

### Tarea 2: el modelo y el generador sintético

- Archivo: `src/lib/dominio.ts` (tipos `Nodo`, `Conexion`, enums `TipoNodo`, `TipoConexion` — los nombres del concepto § Modelo de dominio),
  `src/lib/sintetico.ts` (+ test)
- Qué hacer: `generarGrafo({ nodos, semilla })` puro. Constantes con nombre en `src/lib/constants/` (cantidad, ramas, densidad).
- [ ] Hecha
- [ ] Test: misma semilla → mismo grafo; 500 nodos; toda conexión apunta a nodos que existen

### Tarea 3: layout de fuerzas

- Archivo: `src/lib/layout.ts` (+ test), `src/lib/d3-force-3d.d.ts`
- Qué hacer: `calcularLayout(grafo, ticks)` → `Map<id, posicion>`. Medir cuánto tarda con 500 nodos; si > 200 ms, mover a Worker.
- [ ] Hecha
- [ ] Test: posiciones finitas para todos los nodos; dos corridas con la misma semilla dan lo mismo

### Tarea 4: la escena y la entrada en VR

- Archivo: `src/escena/Grafo.tsx`, `src/escena/Nodos.tsx`, `src/escena/Aristas.tsx`, `src/escena/Etiquetas.tsx`, `src/App.tsx`
- Qué hacer: `<Canvas>` + `createXRStore()` de `@react-three/xr` + botón "Entrar en VR". Nodos por D2, aristas por D2, etiquetas por D3.
  Selección con el rayo del control: el nodo seleccionado muestra título y **qué lo bloquea** (sus `DEPENDE_DE`/`BLOQUEADA_POR` abiertas).
  `r3f-perf` visible solo en desarrollo.
- [ ] Hecha
- [ ] Probado en el PC con el emulador de visor (IWER, que trae `@react-three/xr`)

### Tarea 5: medir en el Quest 3S

- Qué hacer: `quest-despierto -- adb reverse tcp:5173 tcp:5173` → Quest Browser `http://localhost:5173` → Entrar en VR.
  Anotar FPS (r3f-perf) con 100, 300 y 500 nodos; capturar con `quest-ver`. Probar legibilidad: ¿se lee el título a 1 m? ¿se distingue la rama por color?
- [ ] Hecha
- [ ] Resultado escrito en `docs/decisions/DECISION_3D.md` (sigue R3F, o plan B) con los números

## Criterios de Aceptación

- [ ] 1 · 500 nodos + sus aristas a **≥ 72 FPS sostenidos** en el Quest 3S (medido, no estimado)
- [ ] 2 · El título del nodo seleccionado y de los cercanos se lee sin esfuerzo; las ramas se distinguen por color
- [ ] 3 · Seleccionar un nodo muestra qué lo bloquea
- [ ] 4 · `type-check`, `lint` y `test:run` en verde; ningún `let`, ningún `any` sin comentario, ningún `Math.random`/`Date.now` en hooks
- [ ] 5 · `DECISION_3D.md` escrita: si 1 o 2 fallan, propone el plan B (Godot 4) y **se para** antes de la FASE 2

## QA

- [x] Colección — no aplica: no hay API en esta FASE
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
