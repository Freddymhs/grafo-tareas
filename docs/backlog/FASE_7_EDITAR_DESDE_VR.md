# FASE 7: EDITAR DESDE EL VISOR

**Destraba**: reordenar el trabajo donde se ve — conectar, cerrar y ver qué se libera sin salir del 3D
**Listo para PR**: no · FASE escrita el 2026-10-16
**Prioridad**: Baja
**Dependencias**: **FASE 6** (VR solo lectura)
**Fuente**: `docs/_CONCEPTO.md` § Fases F3

## Understand

- [x] Entendimiento — no aplica: FASE técnica

## Tareas

### Tarea 1: crear conexión apuntando de un nodo a otro (rayo del control)
- [x] Hecha — 2026-10-17: panel 3D bajo el nodo seleccionado (`escena/PanelAcciones.tsx`, `escena/Boton3D.tsx`): «Este depende de… / bloqueada por… / espera respuesta de…» → el siguiente nodo tocado es el destino → `POST /conexiones`. Los botones son mallas con `onClick`: el rayo del control (`@react-three/xr`) y el mouse disparan el mismo evento. Errores de la API (409 duplicada, 400) quedan como aviso en el panel.

### Tarea 2: cerrar un nodo y resaltar lo que `libera` devuelve
- [x] Hecha — 2026-10-17: «Cerrar» pregunta primero `GET /nodos/:id/libera` y después `PATCH estado: CERRADO`; lo liberado se pinta verde y más grande (`Nodos.tsx`) con el aviso «Se liberan N». «Reabrir» lo deshace. Toda escritura invalida las consultas: el mapa se relee.

### Tarea 3: estado de la app VR con Zustand (practice-wishlist)
- [x] Hecha — 2026-10-17: `zustand` 5.0.14 · `lib/estado-vr.ts` (seleccionado, modo normal/conectando, resaltados, aviso) con la regla del toque pura (`decidirToque`: conectando → el tocado es el destino; nunca un nodo consigo mismo) y 5 tests. El estado del servidor sigue en TanStack Query.

## Criterios de Aceptación

- [x] 1 · Lo hecho en el visor se ve en la PWA sin recargar más que una vez — 2026-10-17, smoke con Chrome contra la API real y dos nodos de prueba (borrados al final): cerrar la DUDA desde la VR → la API dijo que liberaba la TAREA y quedó resaltada; conectar TAREA «depende de» DUDA apuntando → `POST /conexiones`; la PWA, con una sola carga de `/nodos/<tarea>`, lista «bloqueada por» y «depende de» la duda (`f7-*.png`)
- [ ] 2 · Sigue ≥ 72 FPS — **lo mide Freddy con el visor puesto** (`bin/probar-en-visor --api --abrir`). El panel suma 4 botones y 2 textos solo con un nodo seleccionado

## QA

- [x] Colección — no aplica: no expone API
- [x] Auditoría — 2026-10-17: gates de la VR y smoke de punta a punta VR → API → PWA
- [x] Listo para PR — 2026-10-17: commit `954652d` en `main` de `grafo-tareas.vr` (junto con la FASE 6); falta solo el push (Freddy)

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
