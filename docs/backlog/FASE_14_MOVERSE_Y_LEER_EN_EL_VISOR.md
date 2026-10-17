# FASE 14: MOVERSE Y LEER DENTRO DEL VISOR

**Destraba**: que Freddy pueda recorrer el grafo y leerlo en el Quest. Primera prueba con datos reales (2026-10-17): no se podía
mover («si no, no tiene mucho sentido») y las etiquetas se leían al revés
**Listo para PR**: sí · vr `c750fae` · Freddy en el visor 2026-10-17: «ya me puedo mover»
**Prioridad**: Alta — la VR es lo que Freddy quiere ver
**Dependencias**: FASE 13 (el árbol en la VR)
**Fuente**: Freddy en el visor, 2026-10-17 · capturas `quest-ver` del ojo izquierdo

> **Alcance:** solo `grafo-tareas.vr`. Lo que Freddy reportó, nada más; lo demás de usabilidad 3D va a *Propuestas*, sin construir.

## Lo medido

- **Moverse:** la VR no tenía locomoción (ni código ni doc la mencionaban). Solo se caminaba dentro del Guardian; el grafo ocupa una
  esfera de `RADIO_MUNDO` = 4 m.
- **Etiquetas al revés:** `OrbitControls` (para el escritorio) seguía activo dentro del visor y reescribía la cámara cada frame
  antes del render. Los `Billboard` y la elección de las 12 etiquetas cercanas se calculaban contra esa cámara fija, no contra la
  cabeza: vistas desde atrás, en espejo (captura: «[26317] Husky esencial (FASE 30)» invertida).
- **FPS con datos reales:** 72 en el visor (captura 2026-10-17, 227 nodos · 250 aristas).

## Understand

- [x] Entendimiento — 2026-10-17: reporte de Freddy en el visor + capturas; causa de las etiquetas leída en el código (arriba)

## Tareas

### Tarea 1: moverse con los joysticks
- [x] Hecha — 2026-10-17, `escena/Movimiento.tsx`: `XROrigin` + `useXRControllerLocomotion`; stick izquierdo camina hacia donde se
  mira (1,5 m/s), stick derecho gira a saltos de 30° (marea menos que el giro continuo). Sin subir/bajar (la librería solo traslada en
  el plano)

### Tarea 2: las etiquetas miran a la cabeza
- [x] Hecha — 2026-10-17, mismo archivo: `OrbitControls` solo fuera del visor (`useXR((xr) => xr.session)`). Escritorio verificado
  en headless: la órbita sigue funcionando, 227 nodos, 0 errores

### Tarea 3: Freddy lo prueba en el visor
- [x] 2026-10-17: Freddy se mueve por el grafo («ya me puedo mover»); captura `quest-ver`: las etiquetas se leen de frente y se ven
  los dos racimos (HU 19565 y HU 20379) desde afuera. Se abre con ⟳ en la pestaña del navegador, no con el ícono «grafo VR»

## Propuestas — sin construir, las elige Freddy

1. Leyenda flotante: qué significa cada color y tamaño
2. Volver al centro con un botón
3. Modo sentado / de pie
4. Subir y bajar (lo de arriba y abajo de la esfera hoy solo se mira)

## Criterios de Aceptación

- [x] 1 · Gates de la VR: tsc 0 · lint 0 · tests 33/33
- [x] 2 · Freddy en el visor: se mueve por el grafo y las etiquetas se leen (captura)
- [x] 3 · ≥ 72 FPS con los datos reales (captura del visor, 2026-10-17)

## QA

- [x] Colección — no aplica: no agrega rutas
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
