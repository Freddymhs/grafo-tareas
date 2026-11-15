# FASE 10: EL DÍA — EL PARTE, LO QUE ESTÁ EN CURSO Y LOS TRÁMITES DE CIERRE

**Destraba**: llegar a la daily con el parte hecho (terminé / en curso / detenido) sin armarlo a mano, ver de un vistazo si hay más tarjetas en curso de las que se pueden llevar, y que ningún cierre («falta URL commit», evidencias, wiki) se quede sin hacer — lo que pidió Persona F en la evaluación 1
**Listo para PR**: sí · FASE escrita y cerrada el 2026-10-17 (Freddy: «complétalo todo, fase tras fase»)
**Prioridad**: Alta
**Dependencias**: FASE 8 (roles) · FASE 9 (complementos: «para decir», trámite)
**Fuente**: `docs/_CONCEPTO.md` § C11 «Ideas a pedido» (1) parte, (2) cierres, (3) dos tarjetas en curso · memoria `project-evaluacion1-persona-f`

> **Alcance:** leer el grafo y mostrarlo; sin botón de WhatsApp (Freddy: «primero todo bien montado»): el parte se copia.
> Sin migraciones: todo sale de datos que ya hay.

## Understand

- [x] Entendimiento — 2026-10-17. Medido en la base local: **`updatedAt` no sirve para «qué terminé hoy»**: los importadores reescriben cada nodo en cada corrida (las 59 cerradas tienen fecha de hoy). Hay que hacerlos escribir solo lo que cambió (además es lo correcto para C3). «En curso» no está en ningún lado: Todoist lo tenía repartido en secciones (EN CODIGO 2, TESTEADO 3, LISTO PARA PR 3, AMARRAR 2) → cada rol marca en `roles.yaml` qué etapas son trabajo en curso (`curso: true`). Freddy lleva **dos a la vez a propósito** (C11): el aviso es con más de dos, no con más de una. Los trámites de cierre no se crean a mano (C11): salen de las casillas abiertas de `## Cierre oficial` de cada FASE ya lista para PR.

## Tareas

### Tarea 1: los importadores solo escriben lo que cambió (`updatedAt` honesto)
- `guardarNodo` compara y no hace `update` si nada cambió; `actualizados` cuenta solo lo que cambió.
- [x] Hecha — 2026-10-17 (`aplicar-plan.ts`): compara los campos del plan (etiquetas en orden, `vence` por fecha) y escribe solo si algo cambió. e2e del importador Todoist: la segunda corrida da 0 actualizados y los `updatedAt` quedan idénticos. Rojo probado (escribir siempre rompe el e2e).

### Tarea 2: `curso` en `roles.yaml` y `GET /derivado/dia` — terminé, en curso, detenido, para decir
- terminé = TAREA/FASE cerradas desde `desde` (sin notas) · en curso = abiertas en una etapa `curso` de su rol, con si están bloqueadas · detenido = abiertas bloqueadas (con por qué) · para decir = DAILY_ITEM abiertos `EN_DAILY_DE` un ritual · y el límite de en curso (2).
- [x] Hecha — 2026-10-17: `curso: true` en 15 etapas de la plantilla (`dotfiles`) y la copia del área (codigo, coleccion, auditoria, listo · amarrar, cambiar, red · detectar, corregir, verificar · construir, probar · arreglar · conversar, redactar); `leer-roles` lo lee (falso por defecto), `RolesService.columnasEnCurso()`. `GET /derivado/dia?desde=` (por defecto 24 h): `terminado`, `enCurso` (con `bloqueado`), `detenido` (abiertas con etapa y bloqueadas, con `por`), `paraDecir` (con su ritual) y `limiteEnCurso: 2`. e2e `test/dia.e2e-spec.ts` (4: esperar el PR no es en curso, la nota cerrada no es «terminé», fecha inválida 400). Rojo probado (contar todas las columnas como en curso rompe el e2e).

### Tarea 3: trámites de cierre desde las FASE
- `importar:fases`: una FASE con «Listo para PR» tildado y casillas reales abiertas en `## Cierre oficial` deja un complemento trámite «FASE n: falta …» colgado de ella; se cierra solo cuando se tildan.
- [x] Hecha — 2026-10-17: `cierrePendiente()` en `derivar-por-rol.ts` (entregada = «Listo para PR», o la última casilla de QA si el rol no la tiene; sin casillas reales de cierre —tracker: none— no hay trámite) → `traducir-fases.ts` emite el trámite (externo `tramite:fase:n`, etiqueta `complemento:tramite`, `PERTENECE_A` la FASE) abierto con lo que falta, o cerrado con el cierre completo. e2e: FASE 3 lista → «falta URL commit, Evidencias, Wiki»; tildar en una copia y reimportar → cerrado. Rojo probado.
  **Con los datos reales (Laboratorio, solo lectura):** salen 5 trámites (FASE 22, 32-35) y Todoist tenía 13 tarjetas «falta URL commit». Las 8 de diferencia (FASE 23-30) **no tienen «Listo para PR» tildado en su `.md` aunque Todoist dice que el PR se mergeó**: el `.md` quedó atrás de lo que pasó. Es el desfase que D10 quería hacer visible; esos archivos son del Laboratorio y los tilda Freddy.

### Tarea 4: la PWA — vista «El día» con el parte para copiar
- [x] Hecha — 2026-10-17 (`grafo-tareas.web`): `/dia` en la barra (`app/dia/`): aviso si hay más en curso que el límite, en curso (con etapa y «frenada»), detenido (con qué espera), trámites de cierre, para decir y terminé; botón «Copiar el parte» (texto de `lib/grafo/parte.ts`, puro, con test: terminé / en curso / detenido, y «para decir» si hay). `GET /derivado/dia` también trae `tramites`. e2e `dia.spec.ts` con la API simulada (aviso y portapapeles); rojo probado (subir el límite rompe e2e y vitest). Visto en Chrome contra la API real: **«Hay 11 tarjetas en curso y el acuerdo es 2»** (las de Todoist en TESTEADO/LISTO PARA PR/AMARRAR), 2 detenidas, el parte copiado, 0 errores de consola.
  **De paso, contrato arreglado:** las consultas de derivado (hoy puedo, bloqueado, libera, día) mandaban 5 campos y `NodoResumenDto` declara 9 (etapa, etiquetas, prioridad, vence): Orval tipaba campos que no llegaban. Ahora llegan; «Hoy puedo» muestra etiquetas y prioridad.
  **Datos de hoy:** «Terminé» trae 61 porque la base se importó hoy antes de la tarea 1; desde la próxima importación con cambios, `updatedAt` dice la verdad.

## Criterios de Aceptación

- [x] 1 · El parte se copia con un botón, en el formato terminé / en curso / detenido, y sale de los datos (nada escrito a mano) — e2e `dia.spec.ts` lee el portapapeles; probado contra la API real
- [x] 2 · Con más de dos tarjetas en curso, la vista lo avisa y dice cuáles — «Hay 11 tarjetas en curso…» con datos reales; con 2 no avisa (vitest)
- [x] 3 · Una FASE lista para PR sin URL commit aparece como trámite pendiente; al tildar la casilla y reimportar, desaparece — e2e del importador (FASE 3 de la fixture) y `GET /derivado/dia` → `tramites`

## QA

- [x] Colección — no aplica: proyecto personal, sin Postman
- [x] Auditoría — 2026-10-17: API 70 unit · 37 e2e, contrato regenerado; web tsc, eslint, vitest 16, Playwright 7; VR; rojos probados en cada tarea (uno no aplicaba el cambio —`sed` sobre una línea que prettier había partido— y se repitió hasta que falló de verdad).
- [x] Listo para PR — 2026-10-17: commiteada (api `1ea1e2a`, web `d608901`, vr `7f9c99c`, orquestador `f38d1d7`); sin push.

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
