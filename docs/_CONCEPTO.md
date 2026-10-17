> Origen: DEVELOPMENT/concept-grafo-tareas.md (ideación). Desde el 2026-10-16 ESTE archivo es la fuente viva del proyecto.

# grafo-tareas — concepto

Escrito el 2026-10-16 con `/work:resume:new-concept`. Proyecto nuevo, personal. Cuando se construya: `/work:resume:new-project` → `DEVELOPMENT/grafo-tareas/{grafo-tareas.api,grafo-tareas.web,grafo-tareas.vr}` (ver § Cómo se crea el proyecto).

## Lo que decide el resultado — Pareto (leer antes que todo lo demás)

Si una sesión nueva solo lee esto, no se desvía. Cada punto apunta a dónde está el detalle.

1. **El objetivo: reemplazar a Todoist**, no acompañarlo, para trabajo y proyectos (laborales, freelance, personales, de aprendizaje). Todoist entra **una sola vez**, como migración; nunca hay doble escritura (§ Qué es · § Cómo se conecta el grafo).
2. **El valor es lo que Todoist no puede**: dependencias, personas que bloquean, dudas que frenan varias tareas, **ramas de color como entidad** (los círculos 🔵🟢🟠🟣 de Freddy), "hoy puedo…" y "si X contesta, se liberan N". La PWA copia **solo** lo que Freddy usa (§ Lo que Todoist no deja ver · § Modelo de dominio).
3. **Se construye CON el método, no al lado.** `DEVELOPMENT/grafo-tareas/` es un **orquestador**, como el Laboratorio: `refs.yaml`, `CLAUDE.md` que importa `metodo.md`, `docs/backlog/FASE_*.md`, `Tareas/`, `bin/adapters/`, y los tres repos adentro (§ Cómo se crea el proyecto).
4. **Orden fijo, sin saltarse pasos:** **F-1 prueba de portabilidad** → `nuevo-workspace` → `refs.yaml` → **`/work:resume:new-project`** (no se arranca escribiendo código: lee este concepto, elige plantilla con inspección real, planta `_CONCEPTO.md`, registra el draft en `resume.json`) → **`/work:create-backlog`** → **F1.0 la prueba en el visor** → recién ahí la API (§ Estado al 2026-10-16).
5. **F1.0 primero, y chica:** ~500 nodos alrededor en el Quest Browser con R3F. Si no rinde o no se lee, se revisa la decisión del 3D antes de escribir la API. Es la protección contra "la IA dibujando horas sin resultado".
6. **Hecho para que una IA lo construya sin romperlo:** TypeScript en todo, librerías declarativas con documentación (R3F + @react-three/xr, `d3-force-3d`, `<Text>` de drei), plantillas propias con tests. Nada de three.js imperativo a mano (la lección de `helical-scroll-cards`). Sin sobreingeniería: monolito modular, sin microservicios ni MCP, sin login (Tailscale), lo que nadie pide no se escribe (§ Stack).
7. **Lo agnóstico está garantizado por construcción:** la API no conoce Todoist, Azure ni el SAG; solo los adaptadores e importadores nombran herramientas. El switch es `tablero.kind` en `refs.yaml`, y el contrato del tablero ya existe y anda (F0, PORTAR.md).
8. **Las decisiones son de Freddy y ya están tomadas** (12, en § Stack): tres repos separados, Neon, R3F, Orval, Next desde su plantilla, todo en Tailscale. No se re-deciden; si algo choca, se marca y se le pregunta.
9. **Lo que sigue abierto** se confirma antes de importar datos reales: N1 (datos del cliente en Neon), N2 (si `🎯 Crecimiento Profesional` entra), C1-C4 (§ Para confirmar).
10. **Cómo se trabaja el código, siempre:** las reglas globales de Freddy (`~/.claude/CLAUDE.md`: `const`, sin `any`, SSOT, read-before-write, verificar que un chequeo pueda fallar) y su ciclo: FASE → código → `/work:sellar:run` (precommit en bucle + stage + mensaje) → el commit lo corre Freddy salvo que pida lo contrario.

## Propósito

Ver el trabajo como lo que es, una red, y no como el árbol que impone Todoist. Un ítem de la daily pertenece a la daily y a una tarea; una duda bloquea varias tareas; una respuesta de una persona libera una rama entera. Hoy Freddy reconstruye ese mapa cada mañana de memoria, en cuaderno o con emojis de colores dentro de los títulos de Todoist.

La app guarda ese mapa como grafo, lo muestra en 3D dentro del Meta Quest 3S (los nodos alrededor de uno: de lejos casi plano, de cerca se entra entre las ramas) y lo calcula: qué está bloqueado, qué puedo hacer hoy, qué se libera si alguien contesta.

## Qué es / qué NO es

**Es:**
- Un grafo de nodos y conexiones con estado derivado (bloqueado / libre).
- Tres repos: API (fuente de verdad), PWA tipo lista, app VR.
- Personal, un usuario, dentro de la red Tailscale. Hecho con IA: librerías declarativas y con documentación, nunca gráficos a bajo nivel.
- Las **ramas con color** (🔵🟢🟠🟣 de hoy) son entidad de primera clase. Un nodo puede estar en varias ramas; "tarjeta de dos colores" = nodo que une dos ramas.
- **Reemplaza a Todoist** para trabajo y proyectos (laborales, freelance, personales, de aprendizaje). Todoist entra una sola vez, como migración; después se apaga. Nunca conviven escribiendo los dos.

**NO es:**
- Un clon de Todoist: solo lo que Freddy usa, más lo que Todoist no puede.
- Multiusuario, ni público, ni con cuentas en la v1.
- App nativa de Android ni React Native (en Quest RN solo hace paneles 2D).
- Sincronización con Todoist, ni bidireccional ni doble escritura: o Todoist o grafo, lo decide `refs.yaml`.
- El tracker del cliente (Azure, Jira…): sigue siendo del cliente y solo se lee. El grafo es el tablero personal.

## Lo que Todoist no deja ver (medido el 2026-10-16, solo lectura)

Leídos: proyecto `TRABAJO` (100 tareas de una lista mayor, el resto no se leyó) y `🚀 Draft trabajo` (7 tareas, completo).

1. Dependencias en prosa: "Depende de: 0.1, 0.2, 0.4" dentro de la descripción. Orden con 0️⃣…5️⃣ (5 tareas); rama con color (25 de 100).
2. Personas como bloqueo: Tomás/Thomas en 22 tareas, Carabantes en 8, Fabián en 4. "BLOQUEO A2 — esperando a Tomás Carabantes".
3. Una duda (W2, W7…) frena varias tareas y vive repetida en cada descripción.
4. Enlaces a mano entre proyectos: "5️⃣ espera en el Draft › C · Recepción".
5. Azure (`[25327]`), PR (5115…) y FASE son entidades, hoy solo texto.
6. Estado repetido a mano: 10 tarjetas "falta URL commit y Evidencias", una por FASE.

## Modelo de dominio

```
Nodo
  ├── id, tipo (TAREA | HISTORIA | FASE | RAMA | DUDA | PERSONA | PR | DAILY_ITEM)   ← HISTORIA, no HU: vocabulario de cualquier empresa
  ├── titulo, descripcion, estado (ABIERTO | CERRADO)
  ├── externo { origen: <texto libre: todoist, azure, jira, github…>, id }   ← para importar sin duplicar; la API no conoce la lista
  ├── color (solo RAMA)
  └── posicion { x, y, z }                               ← memoria espacial del mapa 3D

Conexion
  ├── id, origenId, destinoId
  └── tipo (DEPENDE_DE | ESPERA_RESPUESTA_DE | BLOQUEADA_POR | PERTENECE_A | EN_DAILY_DE)

Derivado (lo calcula la API, nunca los fronts)
  ├── bloqueado(nodo)   = tiene DEPENDE_DE / BLOQUEADA_POR / ESPERA_RESPUESTA_DE hacia un nodo ABIERTO
  ├── hoyPuedo()        = tareas ABIERTAS no bloqueadas
  └── libera(nodo)      = tareas que quedan libres si ese nodo se cierra (cadena completa: WITH RECURSIVE)
```

## Fases — F1 protegida

> **Reordenado por Freddy el 2026-10-16, con la FASE 1 verde** (72 FPS con 500 nodos, `docs/decisions/DECISION_3D.md`):
> el riesgo del 3D ya está descartado, así que el orden pasa a ser **backend → clon de Todoist (PWA) → corte de Todoist → VR**.
> La VR es otra vista del mismo dato que muestra la PWA; el objetivo número uno es reemplazar Todoist (§ Pareto 1).
> Backlog: FASE 2 API · 3 importador · 4 PWA · 5 adaptador `grafo` y corte · 6 VR solo lectura · 7 editar desde VR.
> Lo que sigue de esta sección es el plan original; las F1/F2/F3 de abajo valen como contenido, no como orden.

**F0 — PORTAR: el contrato del tablero. ✅ HECHA y commiteada el 2026-10-16** (ver § Estado al 2026-10-16). Falta solo probar en uso real las operaciones que escriben.

**F1 — el mínimo que entrega valor real: ver el mapa.**
0. **Prueba en el visor, antes de todo:** ~500 nodos alrededor de uno en el Quest Browser con R3F + @react-three/xr, etiquetas con `<Text>` de drei solo en nodos cercanos o seleccionados. Si no rinde o no se lee, se revisa la decisión 9 (plan B: Godot 4) antes de escribir la API.
1. API: módulos `nodos`, `conexiones`, `ramas`, `derivado`. Cálculo de bloqueos con tests (Jest + Supertest). Swagger publicado.
2. Importador Todoist (una dirección, módulo `importador-todoist`): lee `TRABAJO` y `🚀 Draft trabajo`; traduce emojis de orden a DEPENDE_DE, colores a PERTENECE_A rama, "Depende de:" y "esperando a X" del texto a conexiones. Idempotente por `externo.id`.
3. App VR solo lectura: grafo con `d3-force-3d`, ramas por color, seleccionar un nodo muestra título y qué lo bloquea. Posiciones guardadas en la API.

**F2 — reemplazar Todoist.** PWA Next.js con lo que Freddy usa de Todoist (medido: secciones por etapa, etiquetas `bloqueo`/`daily`/`propuesta`/`observacion`/`retro`, prioridades p1/p2, subtareas, pocas fechas, cero recurrentes en TRABAJO) + lo que Todoist no puede (ramas, bloqueos, "hoy puedo…"). Adaptador `grafo` del contrato. Migración única desde Todoist. `tablero.kind: grafo`. Importador de `FASE_*.md` + §ABIERTO.

**F3 — editar desde VR.** Crear conexión apuntando de un nodo a otro; cerrar un nodo; ver lo que se libera.

**F4 — solo si hace falta.** Importador como servicio aparte con Redis + cola. Google OAuth si algún día sale de Tailscale.

## Stack (una fuente por decisión)

| decisión | elegido | fuente | nota |
|---|---|---|---|
| Arquitectura | API NestJS + PWA + app VR, TypeScript en todo | feature, gap (NestJS lifecycle) | 3 piezas, 1 backend |
| Backend | monolito modular (un NestJS, módulos por dominio) | feature | microservicios descartados: un usuario, sin carga |
| Plantilla API | `Freddymhs/template-nest` (Fastify, Swagger, Prisma + adapter-pg, Jest, Supertest, pino, Docker, CI) | feature | reutilizar, no re-armar |
| VR | WebXR: Vite + React Three Fiber + `@react-three/xr` + drei `<Text>` | research | ver § Por qué R3F |
| Base de datos | Postgres gratis en la nube | negocio (Freddy) | ver § Para confirmar |
| Proveedor | **Neon** | research | se apaga y vuelve solo; Supabase pausa a mano tras ~1 semana sin uso |
| Repos | tres separados | Freddy | por eso el contrato generado de abajo |
| Contrato | OpenAPI de la API → **Orval** genera tipos + hooks TanStack Query en los dos fronts | feature | la regla "bloqueado" vive en la API |
| PWA | Next.js desde `Freddymhs/template-nextjs-tanstack` + Serwist | gap (hydration Next), feature | |
| Layout 3D | `d3-force-3d` en el navegador, posiciones persistidas | research | el mapa se memoriza; sin esto es una nube distinta cada día |
| Despliegue | API y fronts en el Mac Mini (Docker), acceso solo por Tailscale, sin login en v0 | feature | Tailscale hace de autenticación. Dónde corre es una clave de `refs.yaml`, no código |
| Integración | **contrato del tablero** en el método (PORTAR) + adaptadores `todoist` (hoy) y `grafo` (API REST) | feature | el método no sabe cuál hay detrás; cambiar `tablero.kind` apaga Todoist. **MCP descartado** (Freddy, 2026-10-16): es otra capa, no sirve a hooks ni a wrappers desatendidos. **Sin doble escritura** (Freddy, 2026-10-16) |

### Por qué R3F y no three.js a mano

`fmarcosdev.helical-scroll-cards` (923 líneas) es three.js directo dentro de React: escena a mano, estado en `useRef`, bucle `requestAnimationFrame` propio, limpieza manual. Su `CLAUDE.md` tuvo que prohibir tocar el loop y advertir "race conditions y doble escritura en el mismo frame". Fue costoso con IA por eso. R3F convierte la escena en componentes (`<Nodo />`), la animación en `useFrame` y la limpieza en automática: desaparecen justo esas reglas. Se prueba en el navegador del PC con emulador de visor y recarga en caliente.

### Descartados para el 3D

React Native (solo paneles 2D en Quest), Meta Spatial SDK (Kotlin, grafo desde cero), IWSDK (nuevo, sin React), `3d-force-graph-vr` (A-Frame, mantenimiento sin confirmar; vale como referencia visual).

## Cómo entra y sale la información — medido el 2026-10-16 en el Laboratorio

**Principio:** el grafo **reemplaza al tablero personal** (hoy Todoist). No es un destino más ni convive escribiendo con Todoist: una doble escritura trae reglas en conflicto y ensucia el método. La API no conoce ninguna fuente: solo nodos, conexiones y ramas. **Lo único que sabe de una herramienta son los adaptadores**: el del tablero (lado método) y los importadores (lado grafo).

**La pieza que falta en el método portable es el contrato del tablero.** `~/dotfiles/claude/PORTAR.md` ya resolvió esto para el tracker del cliente (6 operaciones, un adaptador por herramienta, `ref tracker.*`). Para el tablero personal quedó anotado como "capacidad opcional, no implementado", y hoy 13 comandos `flow` nombran Todoist directo (`ref todoist.project_id`, secciones, etiquetas). Ese contrato es lo que permite reemplazar Todoist sin que el método note el cambio.

### Quién escribe el estado hoy, y cómo

| quién | qué | mecanismo |
|---|---|---|
| Freddy dicta | tarjeta en Todoist (`/flow:todo`, §6 = SSOT de destinos) · casilla en la FASE (`/flow:tildar` → `~/bin/fase-tildar`) | determinista |
| hooks | `fase-tilde` tilda la FASE al escribir un artefacto y **sugiere** mover la tarjeta de Todoist; la mueve la sesión si se acuerda | el eslabón débil: 2026-09-27, 10 de 12 tarjetas a mano sin etiqueta |
| `bin/fases` | lee Azure (PAT) → tilda Evidencias / URL commit en la FASE → `fases.html` parsea las FASE en el navegador | determinista, solo lectura de Azure |
| `/flow:pbi:repartir` | tarjetas del Draft con "Depende de", dudas W#, carriles A/B/C, rondas 1️⃣-3️⃣ | con el sí de Freddy |
| bots Hermes | matrix-nocturno, stale-marker, triage, Jarvis | REST (`~/bin/lib/todoist-api.sh`): el MCP **no carga** en wrappers desatendidos |
| Azure | oficial del cliente | Claude solo lee; Freddy pega a mano |

**El estado vive en cuatro lugares** con proyecciones a mano: FASE (`Destraba`, `Dependencias`, `## Abierto`, casillas — la más rica), secciones de Todoist (proyección movida por un LLM), Azure (oficial), `Tareas/<id>/entendimiento.md` §ABIERTO (preguntas por task, fuera de git).

### Cómo se conecta el grafo — el contrato del tablero

- `refs.yaml`: `tablero: { kind: todoist, project_id, label, secciones }` hoy → `tablero: { kind: grafo, api: <url>, token_env: GRAFO_TOKEN }` mañana. Cambiar `kind` es todo el switch. `tablero: none` donde no haya tablero (convención de PORTAR §Capacidades opcionales: `none` escrito = se salta y se dice; ausente = error).
- **Operaciones del contrato — las 5 medidas e implementadas** (PORTAR.md §El contrato del tablero es la fuente): `pendiente <tipo> <texto> [--vence] [--descripcion]` (tipo ∈ bloqueo · confirmacion · informe · propuesta · observacion · supuesto) · `buscar <palabras>` · `tarjeta <id> <título>` (idempotente) · `etapa <id|FASE n> <etapa> [--titulo]` (exit 4 sin tarjeta) · `borrador <carril> <título> [--descripcion-archivo]`. Salida `<id>\t<content>`; error → exit ≠ 0. `cerrar` y `abiertas` NO existen: ningún flow los pide todavía; se escriben con el primero que lo pida (el adaptador `grafo` probablemente los necesite para "hoy puedo" y "si X contesta").
- **Adaptador `todoist`:** cumple el contrato sobre `~/bin/lib/todoist-api.sh` (REST, ya existe, ya lo usan los bots). Los `flow` pasan de `ref todoist.*` a `ref tablero.*`. Nada cambia para Freddy; se verifica con Todoist funcionando igual. Los hooks que hoy *sugieren* mover la tarjeta pasan a llamarlo: determinista.
- **Adaptador `grafo`:** cumple el mismo contrato contra la API REST (Swagger). Un `pendiente` tipo `bloqueo` = nodo DUDA + conexión `ESPERA_RESPUESTA_DE` a la PERSONA; `etapa` = estado del nodo FASE/TAREA; `abiertas --persona` = `libera(persona)`.
- **Migración, una sola vez:** importador Todoist → grafo (TRABAJO, Draft, y los proyectos personales que Freddy elija), idempotente por `externo { origen, id }`. Después, `tablero.kind: grafo` y Todoist queda solo para lo que el grafo no cubre (ver § Para confirmar, N2).
- Importadores de contexto, en F2: `FASE_*.md` + `entendimiento.md` §ABIERTO (dependencias más ricas que cualquier tablero).
- Sesiones interactivas consultan por el mismo CLI o por HTTP. MCP: no está en el plan.

### Prueba de que sigue agnóstico

El grep de PORTAR §Verificar, aplicado al repo de la API: `grep -rnE "sag\.laboratorio|Laboratorio/|dev\.azure|6VhFQg6v45qcJHPc|todoist" grafo-tareas.api/src` → **0 hits fuera de `importadores/`**. Se corre en el CI.

## practice-wishlist

F1: Jest + Supertest + testing NestJS `[norte+gap]` · SQL recursivo e índices `[norte]` · hydration Next `[gap]` · PWA manifest + Service Worker `[norte]`.
F2+: Clean Architecture (importador como adaptador) `[norte]` · Zustand (estado de la app VR) `[norte]` · Redis + cola `[norte]`, solo en F4.
No entran: RLS (un usuario, no protege nada) · Grafana / OpenTelemetry / Prometheus (observabilidad sin carga que observar).

## Cómo se crea el proyecto — con `/work:resume:new-project`

Regla de Freddy (2026-10-16): los proyectos se crean **solo** con `/work:resume:new-project`, y quedan en `DEVELOPMENT/<nombre-padre>/` con **todos los repos adentro**. Para este concepto:

```
DEVELOPMENT/grafo-tareas/                 ← orquestador (git propio, repo GitHub privado Freddymhs/grafo-tareas)
  CLAUDE.md  refs.yaml  docs/  Tareas/  bin/adapters/  .claude/   ← de la plantilla (nuevo-workspace)
  docs/_CONCEPTO.md                       ← este archivo, plantado por new-project
  grafo-tareas.api/   ← template-nest              (git propio · Freddymhs/grafo-tareas.api, privado)
  grafo-tareas.web/   ← template-nextjs-tanstack   (git propio · Freddymhs/grafo-tareas.web, privado)
  grafo-tareas.vr/    ← template-react-vite + R3F (git propio · Freddymhs/grafo-tareas.vr, privado)
```
**Nombres con prefijo, no `api/ web/ vr/`** (corregido 2026-10-16): el `.gitignore` de la plantilla ignora `<prefijo>.*/`, así el orquestador no versiona los repos de adentro y el nombre local = el de GitHub. `nuevo-workspace … grafo-tareas` usa `grafo-tareas` como prefijo.

Tres repos separados (decisión 6), un solo padre. `new-project` planta el concepto una vez en el padre; cada repo tiene su `README`. El `git init` siempre anclado con `cd` a la ruta absoluta de cada subcarpeta (regla del propio comando).

**El padre es un orquestador** (Freddy, 2026-10-16): el grafo se construye **con el método**, igual que el Laboratorio. Lleva `refs.yaml`, `CLAUDE.md`, `docs/backlog/FASE_*.md` (el backlog sale de `/work:create-backlog` leyendo `docs/_CONCEPTO.md`), `Tareas/`, `bin/adapters/`. Su `refs.yaml`:

```yaml
proyecto: grafo-tareas
rama_base: main
tracker: none                              # no hay tracker de empresa: primer uso real del `none`
tablero: { kind: todoist, ... }            # F0-F1: se trabaja con Todoist por el contrato; en F2 pasa a { kind: grafo, api, token_env }
docs: { dir: docs }
repos:
  api: { typecheck: "pnpm tsc --noEmit", lint: "pnpm lint", test: "pnpm test" }
  web: { ... }
  vr:  { ... }
```

**Por eso PORTAR va primero:** sin el contrato del tablero y el `none`, el método no se puede instalar en un padre sin tracker. Y este padre es el **segundo cliente** que PORTAR §Huecos 4 esperaba para probar que un adaptador reemplaza a otro — uno personal, sin Azure. F0 (el contrato) **no** vive en este padre: es método, va en `~/.claude/commands/flow/` + `bin/adapters/` de cada orquestador.

**Pendiente de resolver al crear (C4):** `new-project` crea el padre y planta `docs/_CONCEPTO.md`; `nuevo-workspace` copia la plantilla del orquestador y **no pisa una carpeta con contenido**. Orden propuesto: `nuevo-workspace` primero (padre vacío → orquestador), después `new-project` sobre ese padre (reusar, no clobbear). Si `new-project` no acepta un padre existente, se le agrega esa opción antes de crear nada.

## Estado al 2026-10-16 — lo hecho y lo que sigue (leer esto primero al retomar)

**Hecho y commiteado (sesión del 2026-10-16):**
- **F0 / contrato del tablero:** `PORTAR.md` §El contrato del tablero (5 ops) · adaptador `~/Volumes/Siigsa/SAG/Proyectos/Laboratorio/bin/adapters/todoist/` (`pendiente buscar tarjeta etapa borrador` + `lib/tablero.sh`, backend falso con `TABLERO_FAKE=<dir>`) · `Laboratorio/bin/tests/test_tablero.sh` 24 casos · `Laboratorio/refs.yaml` `todoist:` → `tablero:` · 6 `flow` (`todo observaciones paircoding pbi/get pbi/repartir postman/build`) + README de comandos llaman `ref tablero.*`, cero `mcp__todoist__*` en `flow/` · hook `~/.claude/hooks/fase-tilde.sh` MUEVE la tarjeta por `ref tablero.etapa` (antes sugería), probado de punta a punta con el falso · `~/bin/sesiones` lee `tablero.secciones` (35 tests).
- **`ref` entiende `none`:** exit 3, también en subclaves; `~/bin/tests/test_ref.sh` 19 casos.
- **Bug arreglado:** `~/bin/lib/todoist-api.sh` paginación rompía con >1 página (TRABAJO tiene 134 tareas); `~/bin/tests/test_todoist_api.sh` 5 casos.
- **Pendientes de PORTAR cerrados:** flows dicen qué hacen con `tablero: none` · plantilla `~/dotfiles/workspace-template/.claude/` trae `settings.json` (deny `.env/.npmrc` con `{{RUTA}}`) + hook `tracker-solo-lectura.sh` sobre `mcp__*__browser_*` (tracker declarado bloquea escrituras; `tracker: none` deja todo; ausente bloquea y dice) · `nuevo-workspace` sustituye `{{RUTA}}` (test 16 casos) · `metodo.md` dice "el orquestador" (9 hits del grep de PORTAR, todos fechados o rotulados).
- Commits de la última ronda pendientes de que Freddy los corra: `/tmp/commit-portar-{commands,bin,dotfiles}.txt` (si ya no existen, ya se commitearon).

**Hecho el 2026-10-16, segunda sesión — pasos 0 a 3:**
- **F-1 ✅ pasada limpia** (`ORIGEN=arbol`: 22 casos + suites 19/17/5/35). Nuevo `~/dotfiles/tests/test_restaurar.sh`; README § Restaurar partido en "1. El método" (clona los 7 repos + symlinks de `~/.claude/`) y "2. Escritorio". Fallas que encontró y se arreglaron: el README no clonaba 5 repos ni los symlinks · `test_todoist_api` pasaba solo con el token real en el entorno (`VAR=x . lib` es temporal) · `test_sesiones` dependía del `sqlite3` del Android SDK · `settings.json` tenía `/home/fmarcosdev` fijo en 8 comandos de hook (→ `$HOME`) · la plantilla no ignoraba `.claude/settings.local.json` (regla global §11; caso nuevo en `test_nuevo_workspace`, 17). Puntero en PORTAR §Receta paso 0.
- **Orquestador creado:** `nuevo-workspace` → `DEVELOPMENT/grafo-tareas/`; `refs.yaml` con `tracker: none`, `tablero: none` (Freddy: apagado hasta F2), `qa: none`, `rama_base: main`.
- **GitHub:** 4 repos privados creados (`Freddymhs/grafo-tareas`, `.api`, `.web`, `.vr`) con `origin` puesto.
- **create-backlog:** `docs/backlog/FASE_1..7` (F1 protegida = FASE 1-4), `docs/diagrams/DIAGRAMAS_COMPONENTES.md`, `docs/flows.md`, `.claude/backlog-progress.json`. **Siguiente: FASE 1 (prueba en el visor).**
- **FASE 1 ✅ (2026-10-16, noche):** 72 FPS con 500 nodos en el Quest 3S, `DECISION_3D.md`: sigue R3F. Freddy reordenó: **backend → PWA → corte → VR**.
- **FASE 2, código verde (2026-10-16, noche):** API con nodos, conexiones, ramas y derivado (`bloqueado`, `hoy-puedo`, `libera` con SQL recursivo); C1-C3 confirmados; `openapi.json` versionado; 17 unit + 11 e2e. Base local en Docker (`127.0.0.1:5433`); Neon y el Mac Mini quedan para cuando haya datos reales (criterio 4). **Siguiente: FASE 3, el importador de Todoist** — antes, N1 y N2 (§ Para confirmar).
- **new-project:** `grafo-tareas.api` ← `template-nest`, `grafo-tareas.web` ← `template-nextjs-tanstack`, `grafo-tareas.vr` ← `template-react-vite` (git propio cada uno, rama `main`); `docs/_CONCEPTO.md` plantado; draft en `resume.json`.

**Sin probar en real:** `pendiente`, `tarjeta`, `etapa`, `borrador` contra Todoist (solo `buscar` corrió real). Se verá en el primer `/flow:todo` o tilde de FASE.

**Huecos de PORTAR que quedan (no frenan al grafo):** `/sigsa:documentar` sin mudar al método · `api.bff` y `api.solicitudes` sin aprobar el import de `metodo.md` (lo hace Freddy abriendo una sesión interactiva en cada uno) · un solo adaptador por contrato (el segundo será `grafo`).

**Paso 0 — F-1, prueba de portabilidad del método (ANTES de crear el proyecto).** Pregunta que responde: *¿mi forma de trabajar se instala en una máquina limpia solo desde GitHub?* Si no, `grafo-tareas` nacería sobre un entorno que solo existe en este ThinkPad.
- **Dónde vive hoy el método (medido 2026-10-16), los 7 repos privados en GitHub:** `Freddymhs/claude-commands` → `~/.claude/commands` · `hooks` → `~/.claude/hooks` · `agents` → `~/.claude/agents` · `skills` → `~/.claude/skills` · `bin` → `~/bin` · `dotfiles` → `~/dotfiles` (de ahí salen por symlink `~/.claude/{metodo.md,CLAUDE.md,settings.json}`, `~/.zshrc`, la plantilla `workspace-template/` y `PORTAR.md`) · `user` → `~/.config/systemd/user`. Secretos fuera de todo repo: `~/.zsh_secrets` (TODOIST_API_KEY, etc.) y los `settings.local.json`.
- **Hueco ya encontrado:** `dotfiles/README.md` § "Restaurar en una máquina nueva" no clona `claude-commands`/`hooks`/`agents`/`skills` ni crea los symlinks de `~/.claude/` → en otra máquina el método no quedaría instalado. F-1 lo cierra.
- **Cómo se prueba sin otra máquina:** un HOME descartable (`export HOME=$(mktemp -d)` en una subshell, o un contenedor `ubuntu` con git/python3/pyyaml/jq/node), con la llave SSH de GitHub disponible. Ahí: (1) clonar los 7 repos con **solo** los comandos del README de restauración; (2) crear los symlinks; (3) correr las suites: `~/bin/tests/test_ref.sh` (19), `test_nuevo_workspace.sh` (16), `test_todoist_api.sh` (5) y `test_sesiones.sh` (35); (4) `nuevo-workspace $HOME/Consu/Cli/Proyectos/Prueba prueba` + `REF_DESDE=… ref proyecto`; (5) que `~/.claude/metodo.md` resuelva y que `head -1` del CLAUDE.md generado sea `@~/.claude/metodo.md`. **Cada paso que falle es un paso que le falta al README:** se agrega y se repite desde cero hasta que una pasada limpia dé todo verde. No se toca el HOME real.
- **Qué NO prueba F-1:** el login de Claude Code, Herdr, Tailscale ni los MCP (requieren cuentas); se dejan listados en el README como pasos manuales.
- **Cierre de F-1:** README de restauración completo y probado; una línea en PORTAR.md (§Receta) que apunte a él. Commit por `sellar`.

**Flujo real con GitHub (para todo proyecto nuevo, empezando por éste):**
1. `nuevo-workspace` crea el orquestador local y hace `git init`.
2. El orquestador se publica como repo **privado** propio (`gh repo create Freddymhs/grafo-tareas --private --source . --push`); cada repo de adentro, como su propio repo privado (`grafo-tareas.api` / `.web` / `.vr`). **Crear repos en GitHub es publicar: se hace con el sí de Freddy en ese momento**, no por defecto.
3. En otra máquina: restaurar el método (F-1) → `git clone Freddymhs/grafo-tareas` → clonar adentro los tres repos con el prefijo → abrir una sesión interactiva en el orquestador y **aceptar el import de `metodo.md`** (PORTAR receta paso 5) → `ref` resuelve y los comandos andan igual.
4. `resume.json` toma `url`/`githubUrl` del `git remote get-url origin` real (regla de new-project): por eso los repos de GitHub existen antes o se completan después.

**Siguiente paso — crear el proyecto (orden decidido, C4):**
1. `nuevo-workspace ~/Volumes/Extended/github/DEVELOPMENT/grafo-tareas grafo-tareas` → orquestador con la plantilla (prefijo `grafo-tareas`: ignora `grafo-tareas.*/`). Ojo: `nuevo-workspace` deriva CLIENTE del abuelo de la ruta (en DEVELOPMENT/ da `github`): revisar el CLAUDE.md generado.
2. Llenar su `refs.yaml`: `tracker: none` (proyecto personal: deja usar el navegador libre), `tablero: { kind: todoist, ... }` copiando el bloque del Laboratorio (F0-F1) — o `tablero: none` si Freddy no quiere tarjetas de este proyecto en TRABAJO; `rama_base: main`; `repos` con gates de api/web/vr.
3. **`/work:resume:new-project` sobre ESE padre — no se arranca escribiendo código.** Es el puente concepto → proyecto, y hace cuatro cosas que no se saltan: (a) **lee este concepto entero** y no re-decide stack; (b) **template-first con inspección real**: descubre en vivo los `Freddymhs/template-*` (`gh repo list`), los clona superficial y compara su `package.json`/README contra el stack de acá — candidatos esperados `template-nest` → `grafo-tareas.api/`, `template-nextjs-tanstack` → `grafo-tareas.web/`; si algo choca con una decisión, lo marca y no la cambia en silencio; **`grafo-tareas.vr/` ← `template-react-vite`** (corregido 2026-10-16: la inspección encontró que sí hay plantilla — Vite 8 + React 19 + Vitest + Playwright + CI; F1.0 le suma R3F + @react-three/xr + drei; Freddy eligió plantilla sobre scaffold limpio); cada repo con git propio, reinit anclado con `cd` a la ruta absoluta; (c) **planta este archivo como `docs/_CONCEPTO.md`** con la línea `> Origen: DEVELOPMENT/concept-grafo-tareas.md` (este original no se borra); (d) **registra el draft en `resume.json`** (`published: false`, `wishlist` = la practice-wishlist de acá), validado. No commitea. Reusar el padre que dejó `nuevo-workspace` (no clobbear; si el comando no acepta padre existente, agregarle esa opción antes).
4. `/work:create-backlog` lee `docs/_CONCEPTO.md` → `docs/backlog/FASE_*.md`, con el formato del método (`/work:resume:new-concept` §B): cada FASE abre con `**Destraba**:` y no puede faltarle `## Understand`, `## QA` ni `## Cierre oficial en Azure`. Acá no hay tracker de empresa (`tracker: none`): esa última sección se escribe `- [x] Cierre oficial — no aplica (tracker: none)`, nunca se borra. El visor `fases.html` es del SAG (`Laboratorio/bin/fases`): este proyecto no lo tiene hasta que se pida. **La primera FASE es F1.0: la prueba en el visor** (~500 nodos alrededor, R3F + @react-three/xr, `<Text>` solo en cercanos/seleccionado, servida por Tailscale y abierta en el Quest Browser; medir FPS y legibilidad; si falla, revisar decisión 9 → Godot 4).
5. Recién con F1.0 verde: API (NestJS, Neon, módulos nodos/conexiones/ramas/derivado) e importador Todoist de una dirección.

**Contexto del visor para F1.0 (ver memoria `quest-3s-setup`):** Quest 3S en Tailscale `quest-3s` 100.70.171.33; trabajar por adb siempre envuelto en `~/bin/quest-despierto -- <cmd>`; con la VPN del trabajo (FortiClient) el PC llega al visor solo por Tailscale (relay, lento); `tailscale-guardia.timer` repara `tailscale0`; `quest-ver` captura lo que se ve.

## Fuera de alcance v1

Copiar funciones de Todoist · multiusuario · móvil nativo · sincronización bidireccional · Azure/GitHub como importadores (quedan como `externo.origen` reservados).

## Riesgos

- **Quedar casado con un cliente (Azure/SAG):** el modelo nació midiendo el Laboratorio. Mitigación: la API no conoce fuentes; `HISTORIA` en vez de `HU`; `externo.origen` es texto libre; el grep de § Prueba de que sigue agnóstico corre en CI; los importadores son el único lugar que nombra una herramienta.
- **Gold-plating:** 3 repos + 3 plantillas + Neon ya es infraestructura. Por eso F1 no tiene PWA: primero probar si el 3D aclara.
- **Legibilidad en el visor:** etiquetas con cientos de nodos; mitigación en F1.0 (texto solo en nodos cercanos/seleccionados; un reporte en Quest 3 subió el framebuffer scale a 1.35 por parpadeo con troika).
- **Datos del cliente en un tercero (Neon):** ver § Para confirmar.
- **Importador frágil:** traduce emojis y prosa; es heurístico. Cada regla con test y con el caso real de Todoist como fixture.
- **PWA instalada en Quest:** Meta solo documenta el empaquetado para apps en su tienda; en v0 se abre por URL (Tailscale) y se guarda como favorito. No depender de la instalación.

## Para confirmar

- **C1 (código) — ✅ CONFIRMADO por Freddy 2026-10-16:** decidí que "bloqueado / libera" se calcula en la API (`WITH RECURSIVE` sobre `Conexion`) y los fronts solo lo reciben, porque con tres repos una regla duplicada se desincroniza · ¿confirmás?
- **C2 (código) — ✅ CONFIRMADO por Freddy 2026-10-16:** decidí guardar `posicion {x,y,z}` en `Nodo` para que el mapa 3D sea estable entre sesiones · ¿confirmás?
- **C3 (código) — ✅ CONFIRMADO por Freddy 2026-10-16:** decidí que todo importador sea idempotente por `externo { origen, id }`, no por título · ¿confirmás?

- **C4 (código) — ✅ HECHO 2026-10-16 (nuevo-workspace → new-project sobre el mismo padre):** orden `nuevo-workspace` → `new-project` sobre el mismo padre, ver § Cómo se crea el proyecto · ¿confirmás?
- **N2 (negocio, Freddy):** alcance del reemplazo. El grafo cubre trabajo y proyectos (laborales, freelance, personales, de aprendizaje). Decidí dejar fuera `RUTINA` (hábitos), `Regalos`, `social` y lo que vive en Reminders (vida diaria): siguen donde están. Confirmar si `🎯 Crecimiento Profesional` (empleo, estudio) entra en F2 o después.
- **N1 (negocio, Freddy)** — base local en Docker mientras se construye (Freddy 2026-10-16); Neon recién con datos reales, y N1 se confirma antes: HU, dudas y nombres de personas del cliente (SIIGSA/SAG) quedarán en Neon, un tercero. Decidí seguir porque es Postgres cifrado en tránsito y uso personal; confirmar contra las reglas de confidencialidad del cliente antes de importar datos reales. Default si no: anonimizar nombres de personas en el importador.

## Prompt para retomar (pegarlo tal cual en una sesión nueva o después de /compact)

```text
Retomamos grafo-tareas. Antes de hacer nada, lee entero ~/Volumes/Extended/github/DEVELOPMENT/grafo-tareas/docs/_CONCEPTO.md (§ "Lo que decide el resultado — Pareto" y § "Estado al 2026-10-16" primero) y docs/backlog/README.md + FASE_1_PRUEBA_VISOR.md. Esa es la única fuente: el chat anterior no existe.

Reglas para esta sesión:
- No re-decidas nada de § Stack ni de § Pareto. Si algo choca con el concepto, lo marcas y me preguntas.
- Hechas: F-1, orquestador, backlog, FASE 1 (72 FPS, DECISION_3D) y el código de la FASE 2 (API, docs/backlog/FASE_2_API_GRAFO.md). Orden vigente: backend → PWA (FASE 4) → corte (FASE 5) → VR (FASE 6). Ahora: FASE 3 (importador Todoist), que pide N1 y N2 confirmados antes de tocar datos reales.
- Instalar dependencias (npm i) es instalador: me confirmas antes.
- Crear repos o pushear es publicar: me preguntas en ese momento.
- Commits: por /work:sellar:run, y los corro yo salvo que te pida que los corras tú.
- Mis reglas globales (~/.claude/CLAUDE.md) aplican a todo el código.
- Para trabajar por adb con el visor, siempre ~/bin/quest-despierto -- <cmd> (memoria quest-3s-setup).
- Lo abierto (N1, N2, C1-C4 en § Para confirmar) se confirma antes de importar datos reales de Todoist (FASE 3).

Primer paso: FASE 3, Understand — medir TRABAJO y Draft de nuevo (solo lectura) y confirmar N1/N2 conmigo antes de escribir el importador. Parado en grafo-tareas.api/. Base local: `docker start grafo-tareas-postgres`.
```
