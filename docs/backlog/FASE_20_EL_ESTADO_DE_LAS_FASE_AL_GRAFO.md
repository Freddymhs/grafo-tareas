# FASE 20: EL ESTADO DEJA DE ESCRIBIRSE EN LAS FASE Y VIVE SOLO EN EL GRAFO

**Destraba**: que cada cosa tenga un solo dueño: la FASE es el plan y la memoria de programación de una PBI; el estado (qué
espera, qué falta, quién responde) vive solo en el grafo. Hoy el mismo hecho se escribe en 3 a 6 lugares y eso alimenta el
bucle de pregunta y respuesta
**Estado**: sin rama · hecha el 21-10 · commits: `~/.claude/commands` `ef62def`, `~/dotfiles` `853c159` (con el sí de
Freddy; pusheados). Adoptada en la FASE 21
**Azure**: no aplica (tracker: none)
**Tipo**: devex
**Dependencias**: FASE 19 (Freddy prueba los comandos con una task real)
**Fuente**: Freddy, 20-10: «no podemos empezar a sacar cosas… de estado dentro de las fases y lo dejamos directo en el grafo» ·
«una vez que pruebe todos los comandos… y vea que esté bien… ese momento va a ser cuando voy a hacer el cambio. Pero aún no me
siento seguro, es muy peligroso» · «revalídalo mucho… de hacerlo mal… puede producir problemas gigantescos»

## El hueco, medido

- El 19 y 20-10, una sola decisión (no mandarle el esquema a Thomas) se escribió en 6 lugares: 5 frases de la FASE 18 del
  Laboratorio, el esquema, el índice del backlog, 3 nodos del grafo y la memoria.
- Revalidado el 20-10 leyendo **41 archivos** que abren FASE: scripts, hooks, el importador del grafo, `fases.html`,
  `calidad.html`, los comandos y las plantillas. El primer mapa (hecho grepeando solo algunos encabezados) tenía 7 errores;
  este es el corregido.

## Las decisiones

### D1 · No se toca nada hasta que Freddy pruebe los comandos — Freddy, 2026-10-20 `[código]`

Primero recorre los comandos con trabajo real y mira `fases.html`, `calidad.html` y el grafo. Cuando esté seguro, dice
«hagamos el cambio». Hasta entonces esta FASE es solo el plan.

### D2 · Lo que lee un script o un hook no se toca — revalidado 2026-10-20 `[código]`

| parte de la FASE | forma exacta | quién la lee |
|---|---|---|
| nombre del archivo | `FASE_<n>_<NOMBRE>.md` | las dos páginas, `bin/fases`, los hooks, `~/bin/fase-tildar`, el importador |
| título | `# FASE n: título` | importador (número y título del nodo), hook `fase-tilde` |
| `**Azure**:` | `task NNNNN`, la task como primer número de 5-6 dígitos | las dos páginas (exigen la palabra `task` para el link), `bin/fases`, el importador, hooks `fase-tilde` y `fase-casillas`, `~/bin/sonar` (el aviso de tildar), `Laboratorio/bin/pbi-estado`, `/flow:daily` (`ref docs.campo_task`) |
| `**Tipo**:` | `calidad` / `producto` / … | las dos páginas, `bin/fases`, `fase-tilde`, el importador (rol y columnas) |
| `**Dependencias**:` | cita «FASE N» **en su primera línea** | importador: cada una es una conexión DEPENDE_DE. Hook `fase-casillas` (desde el 20-10): si la FASE citada no tiene `- [x] Mergeado` en su `## QA`, avisa «❌ NO ABRIR EL PR» |
| `**Servicios para probar**:` (nuevo, 21-10) | nombres separados por coma; lo que va entre paréntesis se ignora; `ninguno` | `Laboratorio/bin/pbi-estado`, `~/bin/areas/laboratorio-carril` (`--servicios`), `Laboratorio/.claude/espacio-carril.md` (un pane por servicio) |
| `**Corto**:` (planeado, 21-10) | el nombre corto de la task | `/flow:daily` lo usa si existe; la sesión control lo va a agregar para el título de los spaces |
| `**Destraba**:` | texto | importador: va a la descripción del nodo FASE |
| `**Estado**:` | **solo** la rama entre backticks | `/flow:paralelo` (rotula el space «FASE n») |
| secciones y casillas | `## Understand` (Entendimiento) · `## Tareas` · `## QA` (Colección, Auditoría, Listo para PR, Mergeado) · `## Cierre oficial en Azure` (URL commit, Evidencias, Wiki actualizada) | las dos páginas, `bin/fases` (además **escribe** las casillas del Cierre que Azure confirma), `fase-tilde`, `fase-casillas`, `fase-tildar`, el importador, `~/bin/sonar` (`- [x] Mergeado`), `/flow:daily` (la primera `- [ ]` de `## Tareas` como próxima acción) |
| los `###` de `## Tareas` | el nombre decide el grupo | `calidad.html` y el importador (amarrar/cambiar/red), `fase-tilde`, el espacio de carril (`### Microservicio (…)` / `### BFF (…)`: qué repos abrir) |
| `docs/backlog/README.md` | la tabla | `/work:backlog:next`, `:review`, `:sync` (la reescribe), `/flow:postman:build` (qué FASE es de cada task), el contraste de docs del precommit, `bin/whatsapp-digest` |

Las dudas del grafo no salen de las FASE: el importador las toma de `Tareas/<id>/entendimiento.md`, sección «⚠️ ABIERTO».

### D3 · Lo que se saca: la prosa de estado en lo que NACE, no en las FASE que ya existen `[código]`

- Las FASE nuevas no traen la línea `**Listo para PR**:` del encabezado: el estado del PR vive en la casilla de `## QA`.
  Su `**Estado**:` es solo la rama entre backticks; el resto del estado vive en el grafo.
- Las FASE abiertas **no se tocan** (Freddy, 21-10, después del ensayo de la Tarea 4): su encabezado guarda datos que no
  están en otro lado, como PR, commits, la auditoría o la declaración del PR. Se cierran y quedan en solo lectura.
- Las decisiones D-n, «El hueco», «Fuera de alcance» y los criterios **se quedan**: son la memoria de programación.

## Abierto

- Ninguno: el «cuándo» lo decide Freddy (D1).

## Understand

- [x] Entendimiento — revalidado el 20-10 (D2)

## Tareas

### Antes del cambio
- [x] **Tarea 1** · Freddy recorre los comandos con trabajo real (FASE 19) y dice «hagamos el cambio» — lo dijo el
  21-10 («Hagamos el cambio»)
- [x] **Tarea 2** · re-grepear los lectores (pueden haber cambiado desde el 20-10): todo lo que abre `FASE_` en
  `~/.claude/{commands,hooks,skills}`, `~/bin`, `~/dotfiles`, `Laboratorio/{bin,.claude,CLAUDE.md,refs.yaml}` y
  `grafo-tareas/{grafo-tareas.api/src,bin}`; actualizar D2 si aparece uno nuevo — 21-10: 67 archivos tocan FASE y 19
  cambiaron desde el 20-10. Hay lectores nuevos (`fase-casillas` lee `**Dependencias**` y el Mergeado de la citada;
  `sonar`, `pbi-estado` y `/flow:daily`) y un campo nuevo, `**Servicios para probar**`, más `**Corto**` planeado; todos
  van en D2. Ningún lector usa la línea `**Listo para PR**:` (solo la escribe `/work:create-backlog`),
  y `**Estado**` lo sigue leyendo solo `/flow:paralelo`, y solo la rama

### El cambio
- [x] **Tarea 3** · cambiar a la vez lo que **escribe** esa prosa, o vuelve en la próxima FASE: `/work:create-backlog`
  (su línea `**Listo para PR**: no · <por qué todavía no>`), las plantillas de `~/dotfiles/workspace-template/docs/backlog/plantillas/`
  (`**Estado**` = solo la rama) y `/work:resume:new-concept` — 21-10, con el sí de Freddy: `create-backlog` ya no la
  escribe; las 6 plantillas dicen `**Estado**: <solo la rama entre backticks; el resto del estado vive en el grafo>`;
  `new-concept` no escribía ninguna de las dos. Tests de dotfiles (roles) en verde. Commits `ef62def` y `853c159`.
  Faltaba la copia de las 6 plantillas de cada orquestador (`docs/backlog/plantillas/`, la que nombra su `roles.yaml`):
  la de grafo-tareas tenía el «Estado» viejo y se corrigió el mismo día; quedó idéntica a la del método
- [x] **Tarea 4** · ensayarlo en una copia de `Laboratorio/docs/backlog/` (`fase-tildar` acepta `FASE_DIR`) — 21-10:
  aplicada a ciegas, **la D3 pierde información**, así que no se aplica en bloque. De las 20 FASE abiertas, 19 tienen la
  línea `**Listo para PR**:`. Leídas una por una, solo algunas repiten la casilla de `## QA` (la 22: `PR 5090` está en
  las dos). Las demás traen lo que no está en otro lado:
  - **FASE 18:** 12 líneas con la declaración para el PR (la recepción abandonada, `/sigsa:documentar`, la clave que
    falta en Consul, el código de Thomas que se toca, lo que ve el solicitante) y el resultado de Postman.
  - **FASE 30 y 32:** el PR y el commit del merge; en la 32, además, la ruta de la auditoría.
  - **FASE 17:** el cambio de diseño del `q` y su ADR.
  - **FASE 39 y 41:** el «por qué todavía no» (entra después de la 25325; no abrir el PR del BFF antes de su merge).

  El `**Estado**` también trae commits y versiones (FASE 18: un commit por repo con su versión). Las dos páginas leen la
  casilla de `## QA`, no el encabezado, así que sacarla no las rompe; lo que se pierde es memoria.
- [x] **Tarea 5** · aplicar D3 solo en las FASE **abiertas**: las terminadas están en solo lectura (chmod 444 + hook
  `fase-cerrada`) y no lo necesitan — 21-10: **no se aplica**. Con el ensayo a la vista, Freddy eligió no tocar las
  abiertas (D3)

### Probar
- [x] **Tarea 6** · `bin/fases --sin-abrir`, `fases.html` y `calidad.html` iguales que antes; el importador del grafo con los
  mismos nodos y conexiones que antes; `bash ~/bin/tests/test_fase_tildar.sh` en verde — 21-10: ninguna FASE_*.md cambió,
  así que las páginas, `bin/fases` y el importador leen lo mismo que antes. `test_fase_tildar.sh` dio 5/5. Lo nuevo,
  verificado: `create-backlog` tiene 0 líneas `**Listo para PR**:` y las 6 plantillas dicen solo la rama

## Criterios de Aceptación

- [x] 1 · `fases.html` y `calidad.html` muestran lo mismo antes y después, FASE por FASE (ninguna FASE cambió)
- [x] 2 · el importador produce los mismos nodos y conexiones antes y después (no lee nada de lo que cambió)
- [x] 3 · una FASE nueva creada con los comandos ya no trae la prosa de estado (Tarea 3)
- [x] 4 · ninguna FASE **nueva** escribe el estado que vive en el grafo; las abiertas quedan como están (D3)

## Fuera de alcance

- Las FASE terminadas (solo lectura).
- `docs/backlog/README.md`: lo leen 6 comandos y scripts. Sacarlo es otra FASE, que cambia primero a esos lectores.
- Mover las decisiones D-n o el plan al grafo: se quedan en la FASE.

## QA

- [x] Listo para PR — 2026-10-21: commiteada (orquestador `0bef1a0`…`2c43ce0`, pusheados; `~/.claude/commands` `ef62def` y
  `~/dotfiles` `853c159`, sin push); `test_fase_tildar` 5/5 y los tests de roles de dotfiles en verde
- [x] Mergeado — 2026-10-21, con el sí de Freddy: en `main` y pusheado (`~/.claude/commands` `ef62def`, `~/dotfiles`
  `853c159`; el orquestador ya estaba)
- [x] Adoptado — 2026-10-21: la FASE 21 nació de la plantilla corregida, sin «Listo para PR» en el encabezado y con
  `**Estado**: sin rama`

## Cierre oficial en Azure

- [x] URL commit — no aplica (tracker: none)
- [x] Evidencias — no aplica (tracker: none)
- [x] Wiki actualizada — no aplica (tracker: none)
