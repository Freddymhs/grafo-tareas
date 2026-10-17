# FASE 11: UN TABLERO QUE SE ENTIENDE

**Destraba**: que Freddy abra el tablero y entienda cada columna y cada tarjeta sin preguntar — con las FASE como en `fases.html`/`calidad.html` (nombre, task, avance) y no como «FASE 32» suelto
**Listo para PR**: no · FASE escrita el 2026-10-17, desde la primera prueba de Freddy
**Prioridad**: Alta
**Dependencias**: FASE 8 (roles) · FASE 10 (avance de las FASE)
**Fuente**: feedback de Freddy, 2026-10-17 (primera prueba de la PWA, con capturas de `fases.html` y `calidad.html`)

> **Lo que dijo, en corto:** (1) «Entrada» no se entiende: no sabe por qué existe. (2) Hay dos mundos que no se distinguen —tarjetas
> «FASE n» y tarjetas que parecen mensajes— y las FASE no dicen de qué tratan ni su PBI («FASE 2», «FASE 5» solas). (3) Columnas
> como AMARRAR no se recuerdan qué son. (4) El formato de tarjeta de `fases.html`/`calidad.html` «es genial, es el estilo que
> deberíamos mantener». Además (revisión de espacios): columnas estiradas a 8.300 px, 4 de 9 visibles, el alta rápida ocupa media
> pantalla en el teléfono.

## Understand

- [x] Entendimiento — 2026-10-17. Las «FASE n» del tablero son las que dejó el importador de Todoist: solo el título (18 del SAG, sin etapa → caen en la Entrada). Las FASE con contenido real viven en los `FASE_*.md` del Laboratorio, que nunca se importaron (C10). Las tarjetas «que parecen mensajes» son las de Todoist sin sección (dolores, supuestos, propuestas fechadas). `fases.html` arma su tarjeta con el nombre del archivo, la task de `**Azure**:` y una línea de avance por etapa; bajo cada columna, una línea que la explica.

## Tareas

### Tarea 1: cada columna se explica — `que:` en `roles.yaml`
- [x] Hecha — 2026-10-17: 39 etapas de los 6 roles con su `que:` (las de `fases.html`/`calidad.html` donde existían); `test_roles.py` exige que toda etapa lo tenga, con su caso rojo.

### Tarea 2: la FASE como en `fases.html` — nombre, task y avance
- `importar:fases`: título `FASE 23 · Sonar Errores Microservicios` (del nombre del archivo), la task de `**Azure**:`, y la línea de avance (`entender ✓ · amarrar 15/15 · cambiar 3/3 · red 4/4 · PR ✗ · falta URL commit…`) como primera línea de la descripción.
- [x] Hecha — 2026-10-17: `avance()` en `derivar-por-rol.ts` (genérica por rol: entender, cada grupo de tareas en el orden de las etapas —o `tareas h/t`—, cada casilla de QA ✓/✗/— y el cierre real), `nombre` y `task` en `leer-fase.ts`; `traducir-fases.ts` titula `FASE n · Nombre · task`. **Calza con las capturas de Freddy** de `calidad.html`/`fases.html` (FASE 18, 22, 23, 30, 34, 36, línea por línea). Tests unit con las fixtures.

### Tarea 3: las FASE del Laboratorio en el grafo, adoptando las «FASE n» de Todoist
- Importar los `FASE_*.md` del Laboratorio (solo lectura) como proyecto `laboratorio`; la «FASE n» que dejó Todoist **es** esa FASE (TRABAJO = el SAG): se adopta por proyecto (`--adoptar todoist`), sin duplicar y sin perder sus conexiones. Resuelve C10 para el SAG.
- [x] Hecha — 2026-10-17: `--adoptar <origen>` en `importar:fases` (por externo `fase:n`, nunca por título; en serie dentro de la transacción). e2e: la «FASE 2» de Todoist pasa al proyecto con su id y su conexión, sin duplicado; rojo probado. **Corrido sobre la base local:** `importar:fases --backlog <Laboratorio>/docs/backlog --tareas <Laboratorio>/Tareas --roles docs/roles.yaml --proyecto laboratorio --adoptar todoist` → 35 FASE (18 adoptadas de Todoist, 17 nuevas), 6 dudas de §ABIERTO conectadas, sus trámites. Los `.md` del Laboratorio solo se leyeron. Queda **0** «FASE n» sin nombre en el grafo.

### Tarea 4: la PWA — tarjeta FASE de `fases.html`, columnas que se explican, espacios
- Tarjeta FASE: nombre + task + avance en verde/rojo. Bajo cada columna, su `que`. «Entrada» → «Sin etapa», explicada. Columnas que no se estiran (scroll propio), más angostas en «Todo», alta rápida compacta en el teléfono.
- [x] Hecha — 2026-10-17: `GET /roles` trae `etapas: [{columna, que}]`; el tablero pone el `que` bajo cada columna (el del rol de la pestaña; en «Todo», el del primero que la declara —ENTENDIMIENTO dice distinto en cada rol—). «Sin etapa» con su explicación. Tarjeta FASE con borde índigo, título con nombre y task, y el avance pintado (`lib/grafo/avance.ts`, puro, con test); la tarea suelta, como antes. Columnas `items-start` con alto máximo y scroll propio, 256 px; el alta rápida muestra tipo/columna/prioridad recién al escribir. **Medido en Chrome con datos reales:** la página mide 971 px (antes 8.300), se ven 5 columnas de 11 (antes 4 de 9), en el teléfono el tablero arranca en el px 269 (antes 389), 0 «FASE n» sola, 0 errores de consola. Web: tsc, eslint, vitest 18, `next build`, Playwright 7 (rojo probado: sin el `que`, el e2e falla).

## Criterios de Aceptación

- [x] 1 · Ninguna FASE del tablero se ve como «FASE n» sola: todas con nombre y avance — medido en Chrome: 0
- [x] 2 · Cada columna dice qué significa — 39 etapas con `que`, exigido por `test_roles.py`; e2e
- [x] 3 · El tablero entra en la pantalla: las columnas cortas no se estiran y cada una hace scroll propio — 971 px de página con datos reales

## QA

- [x] Colección — no aplica: proyecto personal, sin Postman
- [x] Auditoría — 2026-10-17: API 71 unit · 38 e2e, contrato al día; web y VR verdes; rojos probados en las 4 tareas.
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
