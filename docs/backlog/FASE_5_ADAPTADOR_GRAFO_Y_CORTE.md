# FASE 5: ADAPTADOR `grafo` DEL TABLERO Y CORTE DE TODOIST

**Destraba**: que el método escriba en el grafo en vez de Todoist — `tablero.kind: grafo` y Todoist apagado para trabajo y proyectos
**Listo para PR**: no · FASE escrita el 2026-10-16
**Prioridad**: Media
**Dependencias**: **FASE 4** (la PWA reemplaza el uso diario) · FASE 3 (la migración)
**Fuente**: `docs/_CONCEPTO.md` § Cómo se conecta el grafo · `~/dotfiles/claude/PORTAR.md` §El contrato del tablero (5 operaciones)

> **Alcance:** método, no API. El adaptador vive en `bin/adapters/grafo/` de cada orquestador que lo use y cumple **el mismo
> contrato** que `Laboratorio/bin/adapters/todoist/`: `pendiente buscar tarjeta etapa borrador`, salida `<id>\t<content>`,
> exit ≠ 0 en error, exit 4 de `etapa` sin tarjeta. **Sin doble escritura:** el día del corte, Todoist deja de recibir.

## Understand

- [x] Entendimiento — 2026-10-17: releídos el contrato (PORTAR §El contrato del tablero), el adaptador `todoist` del Laboratorio y los comandos que lo usan. **Ningún comando llama a Todoist directo: todos escriben por `$(ref tablero.<op>)`** — `/flow:todo` y `/flow:observaciones` (`pendiente`, `buscar`), `/flow:pbi:get` y `repartir` (`tarjeta`, `borrador`), `/flow:paircoding` y el hook `fase-tilde` (`etapa`), `/vista:entrega` y `/flow:propuesta` (a través de `/flow:todo`). Claves que piden, contadas con grep sobre `~/.claude/commands` y `~/.claude/hooks`: las 5 operaciones + `label`, `secciones.<etapa>` y `entrada.{proyecto,seccion}`. Lo que dice "Todoist" en esos comandos es prosa (*"se completa en Todoist con un click"*), no comportamiento: se reescribe después del corte, y es el repo de comandos, no éste.
  **Lo que el corte tiene que resolver:** (1) `/flow:pbi:repartir` lee `tablero.entrada.proyecto`; sin esa clave **pregunta el proyecto**. El adaptador `grafo` no la usa (el carril es una RAMA), así que el bloque `grafo` la declara igual para que no pregunte. (2) Las 9 etapas de `tablero.secciones` del Laboratorio existen en la API: smoke 2026-10-17 contra la API real, una tarjeta recorrió `codigo · coleccion · auditoria · listo · pr` y una FASE `amarrar · cambiar · red`, todas `movida`/`creada`; nodos de prueba borrados.

## Tareas

### Tarea 1: `bin/adapters/grafo/` con las 5 operaciones contra la API REST
- `pendiente bloqueo` = DUDA + `ESPERA_RESPUESTA_DE` a la PERSONA · `etapa` = estado del nodo FASE/TAREA. Backend falso para tests (como `TABLERO_FAKE`).
- [x] Hecha — 2026-10-17 (en el orquestador, commit del 2026-10-17): `bin/adapters/grafo/{pendiente,buscar,tarjeta,etapa,borrador}` + `lib/tablero.sh` (config por `ref tablero.*`: `api`, `token_env` opcional, `label`, `secciones`; `TABLERO_FAKE` con `nodos.json`/`conexiones.json`; valida `tablero.kind` siempre, así `none` sale 3 también en fake). Traducción: `pendiente bloqueo` = DUDA p1 + `--persona` → `ESPERA_RESPUESTA_DE` PERSONA (se crea si falta; extensión del contrato, ningún flow la pasa aún) · otros tipos = TAREA con prioridad, una etiqueta y `vence` ISO · `tarjeta` = TAREA `[<id>] <título>` en `secciones.entendimiento` (idempotente por prefijo) · `etapa` = PATCH `etapa` (`[<id>]` por prefijo; `FASE n` = nodo FASE con título exacto, como los deja el importador; `--titulo` crea) · `borrador` = TAREA `PERTENECE_A` una RAMA llamada como el carril, etiqueta `borrador`. Smoke contra la API real con un orq temporal: las 5 operaciones, salida `<id>\t<titulo>`, idempotencia, exit 4, 400 de la API bien reportado; todo lo creado borrado (base en 158).
- [x] Mismos 24 casos que `test_tablero.sh`, corridos contra este adaptador — `bin/tests/test_tablero.sh`: los 24 traducidos (en el grafo `vence` es ISO, la FASE es un nodo FASE y el carril una RAMA) + 3 del grafo (DUDA, ESPERA_RESPUESTA_DE, PERTENECE_A) = 27/27.
  **Para decidir en la tarea 2 (Freddy):** las `secciones` del Laboratorio tienen `codigo: EN CODIGO` y `coleccion: Collection Created`, que NO están en `ETAPAS` de la API (lista fija, C9): `etapa 99901 codigo` da 400 "Etapa desconocida". Al cortar: o se agregan a `ETAPAS` en el `.env` de la API, o se mapean a etapas que existan.

### Tarea 2: migración final y corte
- Última corrida del importador (FASE 3) → `refs.yaml` `tablero: { kind: grafo, api, token_env }` en el Laboratorio y acá → Todoist solo para lo de N2.
- [ ] Hecha (con el OK de Freddy en el momento)

**Decisión D10 (Freddy, 2026-10-17): el hook marca en los dos lados.** `fase-tilde` sigue tildando la casilla en la `FASE_x.md` (la fuente) y, por `tablero.etapa`, mueve el nodo en el backend. Dos marcas a propósito: si no coinciden, alguien se saltó un paso, y `importar:fases` lo corrige desde el `.md`. Las vistas conviven: `fases.html`/`calidad.html` (clásicas) y la PWA/VR. La PWA y la VR **muestran** las FASE pero no las editan; editan las conexiones.
Para que las dos marcas caigan en el mismo nodo, el adaptador busca la FASE por el externo del importador (`fases-md:<proyecto>` / `fase:n`, abierta o cerrada) y no por el título, que se repite entre proyectos (C10); si no existe la crea con ese externo. `refs.yaml` necesita `proyecto:`. `bin/tests/test_tablero.sh` 31/31 (4 casos nuevos: externo al crear, mueve la del importador aunque esté cerrada, no toca la «FASE n» de Todoist, no duplica). Probado contra la API real sobre «FASE 6»: movió el nodo `fases-md:grafo-tareas` y dejó intacto el de Todoist; como la prueba cambió su etapa, `importar:fases` la devolvió a la del `.md`.

**Plan del corte (escrito 2026-10-17, para hacerlo juntos).** Antes: (a) la API tiene que estar siempre prendida donde la lean los comandos — hoy corre en el ThinkPad y no sobrevive a un reinicio; el lugar previsto es el Mac Mini + Neon (FASE 2, criterio 4). (b) Decidir C10 o aceptar que conviven las «FASE n» de dos orquestadores.
1. Congelar Todoist TRABAJO: no crear más tarjetas ahí desde ese momento.
2. Última importación: `pnpm importar:todoist -- --proyecto 6VhFQg6v45qcJHPc` y `pnpm importar:fases -- --backlog <Laboratorio>/docs/backlog --tareas <Laboratorio>/Tareas --roles <grafo-tareas>/docs/roles.yaml --proyecto laboratorio --adoptar todoist` (así se corrió el 2026-10-17, FASE 11: las 18 «FASE n» de Todoist quedaron adoptadas).
3. Copiar `bin/adapters/grafo/` al Laboratorio y, en su `refs.yaml`, **agregar `proyecto: laboratorio`** (hoy no lo tiene y el adaptador lo exige: es el `fases-md:laboratorio` de la importación) y reemplazar el bloque `tablero:` por el de `grafo` (el que está comentado en el `refs.yaml` de este orquestador, con `api:` apuntando a la API permanente).
4. Probar en el Laboratorio, sin red de Todoist: `bash bin/tests/test_tablero.sh` (copiado) y una pasada real de `/flow:todo informe "prueba de corte"` → la tarjeta aparece en la PWA.
5. Mover una tarjeta con el hook: tildar una casilla de Understand en una FASE de prueba → `fase-tilde` la mueve en el grafo.
**Volver atrás:** restaurar el bloque `tablero: kind: todoist` (está en git del Laboratorio). Lo creado en el grafo durante la prueba se borra desde la PWA; Todoist no se tocó.

### Tarea 3: importadores de contexto — `FASE_*.md` + `entendimiento.md` §ABIERTO
- [x] Hecha — 2026-10-17 (`grafo-tareas.api`, commit `f06384c`): `src/importadores/fases/` — `leer-fase.ts` (puro: número, título, Destraba, `**Tipo**: calidad`, FASEs citadas en `**Dependencias**`, y la **etapa derivada de las casillas con las mismas reglas de `fases.html`/`calidad.html`**: nada → entendimiento · tarea hecha → codigo · QA Colección/Auditoría/Listo → coleccion/auditoria/listo · calidad: amarrar/cambiar/red/pr · cierre real → aprobado · todo tildado → cerrado; «— no aplica» cuenta para terminar, no como avance) · `leer-abiertos.ts` (viñetas de `## ⚠️ ABIERTO`) · `traducir-fases.ts` (FASE → nodo FASE «FASE n» con etapa, estado CERRADO si terminada, etiqueta `calidad`, Destraba en la descripción; Dependencias → `DEPENDE_DE` entre FASEs del directorio; ABIERTO → DUDA etiqueta `abierto`) · `importador-fases.service.ts` (transacción; cada DUDA frena a su task: TAREA `[<id>]…` `BLOQUEADA_POR` DUDA; un ABIERTO que desaparece cierra su DUDA) · `cli.ts` → `pnpm importar:fases -- --backlog <dir> [--tareas <dir>] [--proyecto <nombre>] [--seco]`. **Precommit (2026-10-17) corrigió dos cosas:** el origen es `fases-md:<proyecto>` (default: el nombre del orquestador), porque con un solo `fases-md` importar el backlog de otro proyecto reescribía estas FASE; y sin `--tareas` las dudas ya importadas no se tocan (antes se cerraban todas). Los dos con e2e; API 46 unit · 20 e2e. Commit `f06384c` en `grafo-tareas.api`. Lo compartido con el importador Todoist salió a `src/importadores/{plan,aplicar-plan}.ts`. Tests: 13 unit (fixtures `test/fixtures/fases/`) + 3 e2e (`test/importador-fases.e2e-spec.ts`); API 45 unit · 19 e2e verdes. Corrido sobre este orquestador: 7 FASEs → 7 nodos (1 ✅ CERRADO, 3 ✅ CERRADO, 2/4/5 EN CODIGO, 6/7 ENTENDIMIENTO) y 10 `DEPENDE_DE`; `Tareas/` vacía → 0 dudas.
  **`ETAPAS` por defecto cambió:** se agregaron `EN CODIGO` y `Collection Created` (las claves `codigo`/`coleccion` del método, que el adaptador ya necesitaba: resuelve el hallazgo de la tarea 1). `GET /etapas` da 13 y el tablero de la PWA muestra dos columnas más.
  **Para confirmar con Freddy (C10):** «FASE n» no es único entre orquestadores. El importador Todoist dejó «FASE 6» del SAG y este importador creó otra «FASE 6» (grafo-tareas): la primera corrida la **adoptó por título** y pisó la del SAG (revertido a mano, 1 nodo y 4 conexiones); ahora no adopta nunca y conviven dos «FASE 6». El adaptador `etapa "FASE 6"` toma la primera. Propuesta: una RAMA (o nodo PROYECTO) por orquestador y FASE `PERTENECE_A` ella; título y búsquedas dentro de la rama.

## Criterios de Aceptación

- [ ] 1 · `/flow:todo` y el hook `fase-tilde` escriben en el grafo sin cambiar una línea de los flows
- [ ] 2 · Segundo adaptador del contrato funcionando: cierra PORTAR §Huecos 4

## QA

- [x] Colección — no aplica: es CLI del método
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
