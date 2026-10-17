# FASE 8: ROLES — UN TABLERO POR TIPO DE TRABAJO

**Destraba**: ver en la PWA el trabajo de cada rol con sus propias columnas (Producto, Calidad, Seguridad, DevEx, Incidente, Negocio) y las FASE junto a las tarjetas — C11, la base antes de los complementos
**Listo para PR**: no · FASE escrita el 2026-10-17
**Prioridad**: Alta
**Dependencias**: FASE 4 (la PWA) · FASE 5 (el importador de `FASE_*.md`)
**Fuente**: `docs/_CONCEPTO.md` § Para confirmar C11 · `~/dotfiles/workspace-template/docs/roles.yaml` (la fuente única, con `tests/test_roles.py` como derivación de referencia)

> **Alcance:** leer `roles.yaml`, no editarlo. Las FASE del Laboratorio no se tocan: el rol sale de `**Tipo**:` y, sin la
> línea, cae en `defecto`. La paridad ya está medida (42/42 FASE dan la misma etapa con `roles.yaml` que con el importador).

## Understand

- [x] Entendimiento — 2026-10-17: el importador deriva la etapa con dos funciones fijas (`etapaTipica`, `etapaCalidad` en `leer-fase.ts`) y `ETAPA_DEL_METODO`; `roles.yaml` dice lo mismo como datos (6 roles, condiciones `siempre · tareas_alguna · grupo · qa · cierre_real · terminada`). **Datos reales (base local):** las tarjetas de Todoist usan dos columnas que ningún rol tiene — `❓ DUDAS EN ESPERA` (4) y `🔎 Precheck fin de sprint` (25) —, así que `ETAPAS` **no** puede ser solo la unión de columnas de los roles: es la lista del tablero (C9) **más** las columnas de los roles que falten. La API no conoce ningún área: lee un `roles.yaml` por `ROLES_ARCHIVO`; sin él, no hay roles y todo sigue como hoy. El rol de un nodo es una etiqueta con la clave del rol (el importador ya ponía `calidad`); sin etiqueta de rol, es el `defecto`.

## Tareas

### Tarea 1: la API lee `roles.yaml` — `GET /roles` y `ETAPAS` = tablero ∪ columnas
- `src/modules/roles/`: carga y valida el archivo (`ROLES_ARCHIVO`), `GET /roles` → `{ defecto, roles: [{ clave, nombre, para, columnas }] }`. `GET /etapas` suma las columnas de los roles que no estén. Filtro `GET /nodos?rol=` (C1: qué nodo es de qué rol lo decide la API).
- [x] Hecha — 2026-10-17 (`grafo-tareas.api`, sin commit): `roles.types.ts` · `leer-roles.ts` (yaml + Joi: versión 1, condiciones conocidas, `defecto` existe, marca en un solo rol, grupo usado existe; un archivo roto no deja arrancar la API) · `roles.service.ts` (`columnas()` sin repetir, `filtroDe`: otro rol = lleva su etiqueta; el defecto = no lleva la de ningún otro; rol desconocido = 400) · `roles.controller.ts` (`GET /roles`). `EtapasService.lista()` = tablero (`ETAPAS`/por defecto) ∪ columnas de los roles: 13 → 27 con los 6 roles. Filtro en `nodos.repository.ts` en `AND` con `etiqueta`. Dependencia nueva `yaml@2.8.2` (con el OK de Freddy). `bin/dev` pasa `ROLES_ARCHIVO=<orq>/docs/roles.yaml`; `.env.example` la documenta. `openapi.json` y los clientes Orval de web y VR regenerados. Tests: unit `leer-roles.spec` (5), `roles.service.spec` (3); e2e `test/roles.e2e-spec.ts` (4, con `overrideProvider` del RolesService: el ConfigModule lee el entorno al importarse). Rojo probado: sin el `NOT` del defecto, el e2e falla.

### Tarea 2: `importar:fases` deriva la etapa con `roles.yaml`
- Port de `test_roles.py` a TS (`derivar-por-rol.ts`), puro; reemplaza `etapaTipica`/`etapaCalidad`/`ETAPA_DEL_METODO`. La FASE lleva la etiqueta de su rol. `--roles <archivo>` (por defecto `<orquestador>/docs/roles.yaml`). Paridad: las 7 FASE de este orquestador dan la misma etapa que antes.
- [x] Hecha — 2026-10-17 (sin commit): `derivar-por-rol.ts` (`rolDeFase`, `derivarEtapa`, `seccion`, `terminada`; `cierre_real` suma «PBI creado», como la referencia) · `leer-fase.ts` devuelve `rol` y la **columna** · `traducir-fases.ts` etiqueta la FASE con su rol (antes solo `calidad`) y frena si la columna no está en `GET /etapas` · `cli.ts --roles`. `ETAPA_DEL_METODO`/`ClaveEtapa` borrados. **Paridad TS = Python 43/43** (35 FASE del Laboratorio, solo lectura, + 8 de acá; 32 producto, 11 calidad) con un script que corre las dos derivaciones sobre los mismos archivos. Este orquestador recibió su copia de `docs/roles.yaml` y `docs/backlog/plantillas/` (lo que `nuevo-workspace` copia a un área nueva; `test_roles.py docs` 0 fallas). Importado: 8 FASE, etiqueta `producto`, etapas iguales a las de antes. API 57 unit · 24 e2e. Rojo probado: ganar la primera etapa en vez de la última rompe 4 tests.

### Tarea 3: la PWA — tablero por rol + «Todo»
- Selector de rol arriba del tablero: «Todo» (todas las etapas, como hoy) y uno por rol (sus columnas). El tablero muestra TAREA **y** FASE (hoy solo TAREA). Las FASE se muestran, no se editan (D10).
- [x] Hecha — 2026-10-17 (`grafo-tareas.web`, sin commit): `tablero.tsx` con pestañas Todo + un rol por `GET /roles` (sin roles, no hay pestañas), dos consultas (TAREA, FASE) con `?rol=` y `keepPreviousData` (sin parpadeo al cambiar) · `lib/grafo/columnas-tablero.ts` (puro, con test): Entrada primero; «Todo» esconde columnas vacías; un rol muestra su flujo entero y lo de etapas ajenas va a «Otras etapas» · `tarjeta-nodo.tsx` marca FASE · `nodo-detalle.tsx`: una FASE no tiene selector de etapa ni Cerrar (D10). e2e `tablero-roles.spec.ts` con la API simulada (rojo probado: sin `?rol=` falla). Visto con Chrome contra la API real: Todo 9 columnas, Producto 8 + «Otras etapas 8» (tarjetas de Todoist en DUDAS/AMARRAR/PR, sin etiqueta de rol), Calidad y Negocio vacíos, 0 errores de consola. Web: tsc, eslint, vitest 13, Playwright 5/5. `next build` OK con el dev levantado (Next 16 separa `.next/dev`).

## Criterios de Aceptación

- [x] 1 · Cambiar una columna en `roles.yaml` cambia el tablero de ese rol sin tocar código — 2026-10-17: una copia con `CONVERSAR` → `CONVERSAR CON FABIÁN`, servida por una segunda API (puerto 3999, cerrada después): `GET /roles` de Negocio y `GET /etapas` la traen. Ojo: la API lee el archivo **al arrancar** (`bin/dev` de nuevo después de editarlo).
- [x] 2 · Las tarjetas y FASE reales siguen en su columna (ninguna etapa de la base queda fuera de `GET /etapas`) — 2026-10-17: las 10 etapas en uso en la base están en las 27 de `GET /etapas` (medido, 0 fuera)

## QA

- [x] Colección — no aplica: proyecto personal, sin Postman
- [x] Auditoría — 2026-10-17: `/work:backlog:review` sin errores (⭐⭐⭐⭐☆). Sin TestSprite (Freddy: «no quiero complicarme con eso»): el gate de la FASE es Playwright — `e2e/tablero-roles.spec.ts` con la API simulada y Chrome real contra la API real (Todo/Producto/Calidad/Negocio, 0 errores de consola) — más API 57 unit · 24 e2e, web vitest 13 · Playwright 5, VR 30, y tres casos rojos probados.
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
