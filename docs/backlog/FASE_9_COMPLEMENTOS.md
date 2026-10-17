# FASE 9: COMPLEMENTOS — LO QUE CUELGA DE UN PBI

**Destraba**: que dudas, decisiones y «para decir» vivan pegadas a su PBI y una duda sepa a quién se escala después — C11, sobre la base de la FASE 8
**Listo para PR**: no · FASE escrita el 2026-10-17; las 6 decisiones, aceptadas por Freddy el mismo día
**Prioridad**: Alta
**Dependencias**: FASE 8 (roles)
**Fuente**: `docs/_CONCEPTO.md` § Para confirmar C11 (complementos, escalera, PBI borrador)

> **Alcance:** un complemento no es un rol: es un nodo chico conectado a un PBI (HISTORIA) o a una task. Los 12 tipos de C11:
> duda de negocio · duda de código · dolor · supuesto · decisión · para decir · propuesta · trámite · apunte · evidencia ·
> trabajo de otro · captura rápida. PBI sin número = HISTORIA borrador.

## Understand

- [x] Entendimiento — 2026-10-17. Medido: `TipoNodo` tiene TAREA, HISTORIA, FASE, RAMA, DUDA, PERSONA, PR, DAILY_ITEM; `TipoConexion` DEPENDE_DE, ESPERA_RESPUESTA_DE, BLOQUEADA_POR, PERTENECE_A, EN_DAILY_DE. Las dos dudas y «para decir» ya tienen tipo (DUDA, DAILY_ITEM + EN_DAILY_DE); los otros 9 no.

**Decisiones — las 6 ✅ Freddy, 2026-10-17:**
1. **Sin migración:** un complemento es un nodo DUDA (las dos dudas) o TAREA (el resto) con la etiqueta `complemento:<tipo>`, conectado `PERTENECE_A` a su HISTORIA/TAREA — mismo patrón que el rol en la FASE 8 (etiqueta, filtro en la API). Alternativa: un valor nuevo en `TipoNodo` por tipo (9 valores, migración de Prisma). Propongo la etiqueta: los tipos son del método y cambian; el enum es esquema.
2. **Los 12 tipos viven en `roles.yaml` del área** (bloque `complementos:` con clave, nombre, tipo de nodo), no en la API: misma SSOT que los roles, la PWA los lee por `GET /roles` (o `GET /complementos`).
3. **La escalera vive en `refs.yaml` del área:** `escalera: { negocio: [codigo, carabantes, tomas-soto|nicolas], codigo: [tomas-soto, carabantes] }` con las personas como nodos PERSONA. Escalar = la DUDA pasa de `ESPERA_RESPUESTA_DE` la persona actual a la siguiente; la anterior queda en la descripción (quién, cuándo).
4. **Decisión = la duda contestada:** cerrar una DUDA pide «quién contestó y dónde quedó» y deja un nodo `complemento:decision` que la reemplaza en el PBI. No se borra la duda.
5. **Para decir** cuelga de un ritual (`daily`, `retro`, `1:1 Fabián`) como DAILY_ITEM `EN_DAILY_DE` el nodo del ritual; el «parte para Fabián» (idea a pedido) sale de ahí.
6. **PBI borrador:** HISTORIA sin `externo` (sin número de Azure); cuando tiene número, se le pone el externo y queda conectada a su origen (rol Negocio → Producto).

**Cómo se baja a código (lo que el diseño de arriba no decía):**
- Cada tipo del catálogo dice su `nodo` (DUDA · TAREA · DAILY_ITEM) y si es `accionable`. Los no accionables (dolor, supuesto, decisión, apunte, evidencia, trabajo de otro) son **notas**: no entran en «hoy puedo» y el tablero las oculta (`GET /nodos?notas=ocultar`); se ven en el detalle de su PBI. Accionables: propuesta, trámite, captura rápida.
- Una duda frena a su PBI: al crearla, el PBI queda `BLOQUEADA_POR` ella; cerrarla (decidir) lo libera — lo derivado ya existente lo calcula.
- La escalera se lee de `refs.yaml` del área (`REFS_ARCHIVO`, como `ROLES_ARCHIVO`). La del SAG va en el `refs.yaml` del Laboratorio (otra área: la escribe Freddy al cortar); acá queda el formato con un ejemplo.
- Un ritual (daily, retro, 1:1) es un nodo DAILY_ITEM con externo `ritual:<clave>`, creado la primera vez; «para decir» es un DAILY_ITEM `EN_DAILY_DE` él y `PERTENECE_A` su PBI. Los rituales se listan en `refs.yaml` (`rituales:`).

## Tareas

### Tarea 1: el catálogo — `complementos:` en `roles.yaml` y lectura en la API
- [x] Hecha — 2026-10-17 (sin commit): `complementos:` (12, con `nodo`, `accionable`, `escalera`) en `~/dotfiles/workspace-template/docs/roles.yaml` y la copia del área; `test_roles.py` lo valida (nodo existente, escalera solo en DUDA, con su caso rojo). API: `leer-roles` lo lee (Joi; `accionable` true por defecto), `GET /roles` lo devuelve, `POST/GET /nodos/:id/complementos` (nodo + `PERTENECE_A` en una transacción; una duda deja al padre `BLOQUEADA_POR` ella), las notas fuera de `hoy-puedo` y de `GET /nodos?notas=ocultar`. 61 unit · 28 e2e (`test/complementos.e2e-spec.ts`, 4). Rojo probado: sin excluir las notas, «hoy puedo» trae el apunte.

### Tarea 2: escalera de dudas — `refs.yaml` del área + escalar desde la PWA
- [x] Hecha (API) — 2026-10-17 (sin commit): módulo `area` (`REFS_ARCHIVO`; `leer-area.ts` lee `escalera` y `rituales` e ignora el resto de `refs.yaml`; `GET /area`). `POST /nodos/:id/escalar` (siguiente de la escalera, o `persona`; mueve el `ESPERA_RESPUESTA_DE` y crea la PERSONA si falta; rastro «- fecha · escalada a X (antes: Y) · ya hecho: contrastar con el código»; 409 al final de la escalera) · `POST /nodos/:id/decidir` (`quien`, `donde`, `texto`: cierra la duda, deja la decisión `PERTENECE_A` la duda y su PBI; el PBI queda libre) · «para decir» pide `ritual` y cuelga `EN_DAILY_DE` el ritual (DAILY_ITEM `ritual:<clave>`, uno solo). `roles.yaml` y `refs.yaml` rechazan claves mal escritas (Joi `unknown(false)`: `allowUnknown` bajaba a los anidados y «acionable: false» pasaba callado; también en `test_roles.py`). `refs.yaml` de este orquestador: `rituales` (daily, retro) y el formato de `escalera` comentado — la del SAG va en el del Laboratorio. API 65 unit · 31 e2e; rojo probado (escalar siempre al primero rompe el e2e). El botón en la PWA es la tarea 3.

### Tarea 3: la PWA — complementos en el detalle del PBI (crear, escalar, cerrar como decisión)
- [x] Hecha — 2026-10-17 (`grafo-tareas.web`, sin commit): `components/complementos-nodo.tsx` en el detalle de todo nodo (la lista con el nombre del catálogo; colgar uno con su tipo, y el ritual solo si es «para decir»; en una duda abierta, Escalar y Decidir con quién/dónde/respuesta; los errores de la API se muestran) · el tablero pide `notas=ocultar` (constante del enum que generó Orval, no un literal repetido). e2e `complementos.spec.ts` con la API simulada (rojo probado: sin mandar el ritual, falla). Smoke en Chrome contra la API real sobre un PBI de prueba que el smoke crea y borra (ritual incluido; la base quedó en 166/98): la duda frena al PBI, Escalar sin escalera en el área muestra el error, Decidir la cierra y el PBI queda libre, el apunte no está en «hoy puedo», 0 errores de consola salvo ese 400. Web: tsc, eslint, vitest 13, Playwright 6. El complemento también aparece en «Conexiones» (es un `PERTENECE_A` real): no se esconde.
  **Encontrado de paso:** un `pnpm start:dev` (`nest start --watch`) olvidado de antes de `bin/dev` le ganaba el 3000 a la API de `bin/dev` en cada reinicio — la PWA hablaba con una API sin roles. Se mató por PID y `bin/dev` ahora falla si la API que responde no trae los roles del área (rojo probado con una API sin roles en otro puerto).

**Revisión propia (2026-10-17, sesión sin humano, sin stagear):** (1) la fecha del rastro y de la decisión salía en UTC —después de las ~21 h de Chile decía el día siguiente— → fecha local (`toLocaleDateString('sv-SE')`); el e2e la compara, y como a esa hora UTC y local coinciden, el rojo se probó con `TZ=Pacific/Kiritimati` (UTC+14): con el código viejo falla, con el nuevo pasa. (2) `ritual` en un complemento que no es DAILY_ITEM se ignoraba en silencio → 400 con el motivo (e2e). Queda como observación, sin cambiar: si una duda se escaló a alguien fuera de la escalera (`persona`), el siguiente «Escalar» sin persona vuelve al primero de la escalera. API 65 unit · 31 e2e.

## Criterios de Aceptación

- [x] 1 · Desde un PBI se crea una duda de negocio, se escala dos veces y se cierra como decisión, y queda todo el rastro — 2026-10-17: e2e `complementos.e2e-spec.ts` (escalera de la fixture: Analista → Senior Back, 409 al final, rastro en la descripción, decisión colgada, PBI libre) y en la PWA el mismo flujo salvo escalar (este orquestador no tiene escalera; la del SAG la escribe Freddy en el `refs.yaml` del Laboratorio)
- [x] 2 · Agregar un tipo de complemento es una línea en `roles.yaml`, sin tocar código — 2026-10-17: una copia con `riesgo:` de más, servida por una API en el 3999 (cerrada después): `GET /roles` trae 13

## QA

- [x] Colección — no aplica: proyecto personal, sin Postman
- [x] Auditoría — 2026-10-17: revisión propia (fecha local, `ritual` de más), gates de los 3 repos (API 65 unit · 31 e2e, contrato al día; web tsc, eslint, vitest 13, `next build`, Playwright 6; VR 30), smoke real en Chrome y rojos probados.
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
