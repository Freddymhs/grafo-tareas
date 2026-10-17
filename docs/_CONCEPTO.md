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

> **Ampliado el 2026-10-17 (C9, Freddy):** `Nodo` lleva además `etapa` (columna del tablero, lista fija = las etapas del método), `etiquetas` (daily, propuesta, observación, retro, supuesto: los "tipos de tarjeta"), `prioridad` 1-4 y `vence`. Y lo que Freddy explicó con `fases.html`/`calidad.html`: **los `FASE_x.md` son el corazón**; sus casillas dan la etapa de cada FASE en dos tableros (flujo normal y calidad). Todoist aporta lo que esos archivos no muestran: las conexiones y las tarjetas sueltas que "no se pueden olvidar". El grafo junta las dos cosas y el 3D las hace visibles.

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
2. Importador Todoist (una dirección, módulo `importador-todoist`): lee `TRABAJO` y `🚀 Draft trabajo`; traduce emojis de orden a DEPENDE_DE, colores a PERTENECE_A rama, "Depende de:" y "esperando a X" del texto a conexiones. Idempotente por `externo.id`. **Corregido el 2026-10-16 al medir TRABAJO completo (FASE 3):** solo `TRABAJO` (N2); los emojis de orden **no** generan DEPENDE_DE (6 casos de contextos distintos, decisión D7); "Depende de" y las dudas W# tienen **0** casos en TRABAJO (vivían en el Draft); lo que sí hay y se importa: subtareas (el padre DEPENDE_DE las hijas), `FASE n` como nodo FASE, y `BLOQUEO/esperando a <persona>` como ESPERA_RESPUESTA_DE.
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

**Hecho el 2026-10-17 (madrugada):**
- **FASE 3 ✅** (`04cbbd6`): importador Todoist, 134 tareas → 158 nodos / 86 conexiones en la base LOCAL (`grafo-tareas-postgres`, 127.0.0.1:5433); idempotente (2ª corrida 0 nuevos). Solo `TRABAJO` (N2), nombres reales (N1).
- **C9 ✅ en la API** (`113012e`, `88f762b`, CI verde): `etapa` (lista fija = las etapas del método, `GET /etapas`, `ETAPAS` env), `etiquetas`, `prioridad`, `vence`, filtros `etapa/etiqueta/rama/q`, `GET nodos` → `{data,total}`, `limit` ≤ 500. Reimportado: 23 ENTENDIMIENTO, 29 CERRADO, 42 sin etapa, p1 12, p2 33, daily 10 — igual que Todoist.
- **FASE 4 tareas 1 ✅ (`1769969`+) y 2 ✅ (`61aaa9f`; review con 2 arreglos SSOT, entraron en `aa187db`):** Orval + 4 vistas + detalle contra datos reales.
- **FASE 4 tarea 3 ✅ (2026-10-17, `aa187db` web · `f06384c` api):** crear (alta rápida en el tablero), cerrar/reabrir y mover de etapa (detalle), conectar/quitar con buscador por `q` y títulos reales. Probado con Chrome contra la API real. Dos arreglos en la API que la PWA destapó: **CORS** (`@fastify/cors` solo deja `GET,HEAD,POST` por defecto → `src/config/cors.ts`, con e2e del preflight) y `PATCH etapa: null` para volver a la entrada. Falta Markdown de la descripción (dependencia: preguntar).
- **FASE 4 tarea 4 (2026-10-17, `aa187db`; cerrada esa noche con `bin/servir-tailnet`):** Serwist (offline de lectura probado sin red: tablero y hoy puedo desde caché, fallback `~offline`), manifest, íconos (cierra el 404 del favicon), `next build --webpack`. Falta abrir por Tailscale en teléfono/Quest con Freddy y decidir webpack vs modo configurator (`@serwist/cli`). **Incidente:** los e2e de la API borraron la base dev (corrían contra `grafo_tareas`); guard `test/setup-e2e.ts` + reimportado (158/86/80, igual que antes).
- **Noche del 2026-10-17 — "terminalo tú" (Freddy), commiteado, pusheado y con CI verde** (api `f06384c`, web `61aaa9f` + `aa187db`, vr `954652d`, orquestador `8b4b34f`): FASE 4 ✅ (Markdown con `react-markdown`, `bin/servir-tailnet`: PWA por HTTPS del tailnet probada con vista de teléfono, offline incluido) · FASE 6 ✅ (VR contra la API con Orval + TanStack Query, posiciones guardadas una vez y estables, bloqueo preguntado a la API, `bloqueo.ts` borrado, texto 3D sin emojis) · FASE 7 ✅ (panel 3D: cerrar y resaltar lo que libera, conectar apuntando, Zustand; probado VR → API → PWA). **Queda en manos de Freddy:** abrir la PWA en el teléfono/Quest y usarla una semana (FASE 4 criterio 1), medir FPS en el visor con datos reales (FASE 6 c1, FASE 7 c2), el corte (FASE 5 tarea 2), C10, y el deploy a Mac Mini + Neon (FASE 2 criterio 4).
- **FASE 4 criterios 2 y 3 ✅ (2026-10-17):** gates completos incluido Playwright (4/4; config corregida: 3001, sin SW) e hidratación sin warnings. **FASE 6 tarea 1 bloqueada por instalador** (`orval` + `@tanstack/react-query` en la VR): preguntar.
- **FASE 5 tarea 3 ✅ (2026-10-17, `f06384c`):** importador de `FASE_*.md` (etapa derivada de las casillas como `fases.html`/`calidad.html`, Dependencias → `DEPENDE_DE`) y de `entendimiento.md` §ABIERTO (DUDAs que frenan a su task). `ETAPAS` por defecto suma `EN CODIGO` y `Collection Created`. Corrido sobre este orquestador: 7 FASEs, 10 dependencias. **C10 abierto:** «FASE n» choca entre orquestadores (pisó la FASE 6 del SAG, revertido): hace falta la dimensión proyecto.
- **FASE 5 tarea 1 ✅ (2026-10-17, en el orquestador):** `bin/adapters/grafo/` cumple el contrato del tablero contra la API (27/27 casos fake + smoke real limpio). Pendiente al cortar (tarea 2, con Freddy): las etapas `EN CODIGO` y `Collection Created` del Laboratorio no existen en `ETAPAS` de la API.
- **Desvío corregido por reclamo de Freddy:** ahora las tareas se toman con `/work:backlog:next`, se auditan con `/work:backlog:review` y se sellan con `/work:sellar:run`; los commits los corre Freddy salvo que diga "hazlo". Reglas aprendidas en `CLAUDE.md` del orquestador (§Trampas: inyección de `fetch`, CLI desde `dist`, e2e en serie, prettier en generados, specs sin `let`, derivado sobre TAREAS, políticas de pnpm 10, CI con la versión de `packageManager`).
- **Lo que Freddy explicó con `fases.html`/`calidad.html`:** los `FASE_x.md` son el corazón; sus casillas dan la etapa en dos tableros (flujo normal y calidad). Todoist aporta conexiones y tarjetas sueltas. El grafo junta ambos; el 3D hace visibles las conexiones. → FASE 5: importador de `FASE_*.md` como nodos FASE con etapa derivada de las casillas (como `bin/fases`).
- **FASE 8 — roles (2026-10-17, tarde, sin commit):** la API lee `roles.yaml` (`ROLES_ARCHIVO`; `GET /roles`, `GET /nodos?rol=`, `GET /etapas` = tablero ∪ columnas), `importar:fases` deriva rol y etapa con él (paridad con `test_roles.py` 43/43) y la PWA tiene pestañas por rol con tareas y FASE. Dependencia nueva `yaml` (OK de Freddy). API 57 unit · 24 e2e; web vitest 13 · Playwright 5; VR 30. Detalle en `FASE_8_ROLES.md`.
- **FASE 9 — complementos (2026-10-17, tarde, sin commit):** catálogo de 12 en `roles.yaml` (nodo, accionable, escalera), `POST/GET /nodos/:id/complementos`, `escalar`, `decidir`, rituales y escaleras desde `refs.yaml` (`REFS_ARCHIVO`, `GET /area`), notas fuera de «hoy puedo» y del tablero; PWA con la sección Complementos en el detalle. API 65 unit · 31 e2e; web Playwright 6. Detalle en `FASE_9_COMPLEMENTOS.md`.
- **FASE 10 — el día (2026-10-17, noche):** `GET /derivado/dia` (terminé, en curso según `curso: true` de `roles.yaml`, detenido, para decir, trámites) y la vista `/dia` con «Copiar el parte» y el aviso de más de 2 en curso (con datos reales: 11). Los importadores solo escriben lo que cambió (`updatedAt` honesto). Trámites de cierre automáticos desde las casillas de `## Cierre oficial`; con los datos del Laboratorio: 5 trámites, y 8 FASE (23-30) con PR mergeado pero sin «Listo para PR» tildado en su `.md`.
- **FASE 11 — un tablero que se entiende (2026-10-17, desde la primera prueba de Freddy):** las FASE como en `fases.html` (nombre, task, avance en verde/rojo), cada columna con su `que`, «Entrada» → «Sin etapa» explicada, las 35 FASE del Laboratorio importadas adoptando las 18 de Todoist (C10), columnas con scroll propio (la página pasó de 8.300 a 971 px).
- **FASE 12 — despliegue en el Mac Mini (2026-10-17, tarde):** API + Postgres + PWA + respaldo diario en Docker, solo `127.0.0.1`, publicados por `tailscale serve` (`:8443` API, `:10000` PWA). Postgres en Docker y no Neon (Freddy; N1). `bin/desplegar` idempotente (BuildKit: `BUILDX_NO_DEFAULT_ATTESTATIONS=1`) y `refs.yaml` → `despliegue` como fuente de dónde corre. Datos del PC migrados (214 · 137, idéntico); respaldo restaurado en base de prueba. Pendiente de Freddy: teléfono y Uptime Kuma.

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

## Cómo trabaja Freddy — el árbol que el grafo tiene que mostrar (Freddy, 2026-10-17)

> Fuente: lo que Freddy explicó el 2026-10-17 + su cheatsheet (`ah` → `~/Desktop/automatizandosag.md`) + `/flow:pbi:repartir`
> + las 7 tarjetas reales del Draft. **Leer antes de tocar un importador o el modelo**: sin esto se inventa la estructura.

1. **Azure:** los analistas refinan una **HU** y se la asignan. Una HU tiene varios PBI (niveles exactos: § Para confirmar C12).
2. **«🚀 Draft trabajo» = la etapa previa.** `/flow:brechas` (qué ya existe en el código) y `/flow:pbi:repartir` (la HU →
   **piezas `N.M`** ≤ 1 día, con «depende de»), en **carriles** (zona de código: A · Bandeja, B · Acceso y KPIs, C · Recepción)
   y **rondas** (1️⃣ cimientos · 2️⃣ paralelo · 3️⃣ cruce). Formato fijo de la tarjeta: `<ronda> <HU> · <N.M> · <título> · <task|por crear>`;
   la descripción empieza con `# N.M · título  HU <n> · task <id|sin task> · reparto <fecha>`; el encaje va en la descripción del proyecto.
3. **El PBI se crea cuando la pieza está clara** (lo crea Freddy, salvo que un compañero ya lo haya hecho). Al tomarla, la tarjeta
   pasa a **TRABAJO** como `[<id>] <título>` (etiqueta `board`) y la mueven los comandos y el hook `fase-tilde`.
4. **La FASE** (`FASE_N.md`, `new-concept` tras `pbi:get` → `build` → `understand`) es el 80 % definido: cabecera con `**Azure**: task <id>
   (padre HU <n>)`. No se crean todas de golpe: Todoist es la etapa previa.
5. Después: código, colección, auditoría, PR, cierre (URL commit, evidencias, wiki).
6. **TRABAJO = lo asignado, primero.** Cuando se vacía, se avanza el Draft.

**El árbol:** HU → piezas / PBI → FASE → tarjeta de TRABAJO, con dudas, personas y notas colgando. **Medido el 2026-10-17 en
producción:** el backend NO tiene las HU, ni el Draft, ni el enganche tarjeta `[id]` ↔ FASE (48 de 85 tareas abiertas sueltas; en la
VR, puntos grises sin forma). Todo lo que falta está escrito en formatos fijos que los comandos de Freddy ya producen: se **lee**, no se inventa.

## Para confirmar

- **C12 (2026-10-17, abierto — bloquea el modelo del árbol; respondido por las fuentes, falta el «sí» de Freddy):** (1) HU = PBI, un nivel; debajo Tasks; FASE = Task — `Laboratorio/docs/referencia/equipo-y-proceso.md` § Vocabulario (verificado en Azure el 2026-09-13). (2) Tarjeta y FASE = la misma task vista dos veces; la tarjeta `PERTENECE_A` su FASE (D10 las marca a las dos). (3) La pieza es la misma tarjeta que pasa a TRABAJO (`/flow:pbi:repartir` §5) → un nodo. Reglas en `docs/backlog/FASE_13_EL_ARBOL_HU_PIEZA_TASK.md`. Lo original: (1) ¿19565 es una HU o un PBI, y 24972 (la de la FASE 10) es un PBI o una
  task? La FASE dice «task 24972 (padre HU 19565)» y el README del Laboratorio «tasks… del PBI 19565». (2) La tarjeta `[25476]` de TRABAJO
  y la «FASE 32 · … · 25476» del `.md`: ¿un solo nodo o la tarjeta pertenece a la FASE? (3) La pieza «3.1» del Draft que pasa a TRABAJO
  como `[263xx]`: ¿la misma cosa que avanza, o la del Draft queda como plan?

- **C11 (2026-10-17, en conversación con Freddy) — roles y complementos.** Lo confirmado y lo abierto:
  - **Roles = tipo de trabajo, cada uno con sus columnas.** Confirmados: **Producto** (features/PBI), **Calidad** (Sonar, refactor, performance, tests rojo→verde; absorbe la "Confiabilidad": logs, alertas, CI), **Seguridad**, **DevEx** (solo código y herramientas del equipo), **Incidente** (bug en producción), **Negocio** (detectar, conversar con el analista o Fabián, redactar el PBI; el PBI aprobado pasa a Producto y queda conectado a su origen). Descartado: Investigación. Regla: todo rol que no sea Producto termina en «adoptado/mostrado», no en «hecho» (evidencia: en DOT el commit de tooling `85636aa` quedó fuera de `main`/`dev` y el `ARCHITECTURAL_REVIEW.md` quedó en una carpeta gitignoreada).
  - **Las FASE del Laboratorio no se editan:** el rol sale de `**Tipo**:` (35 FASE: 11 `calidad`, 4 `funcional`, 20 sin línea → Producto). Abierto: si «funcional» pasa a ser el nombre oficial de Producto.
  - **SSOT propuesto:** `roles.yaml` con nombre, marca `**Tipo**`, secciones de tareas, columnas, derivación de etapa y plantilla de FASE; lo leen `new-concept`/`create-backlog`, `importar:fases`, la PWA y `bin/fases`. Abierto: dónde vive (propuesta: `dotfiles`, como parte del método).
  - **Complementos = no son roles, se cuelgan de un PBI** (12 tipos encontrados leyendo las 141 tarjetas de TRABAJO y Draft): duda de negocio · duda de código · dolor (PBI vs código) · supuesto · decisión (duda contestada: quién, cuándo, dónde quedó registrada) · para decir (daily, retro, 1:1, mensaje) · propuesta · trámite · apunte de dominio · evidencia · trabajo de otro · captura rápida.
  - **Escalera de una duda (Freddy):** de negocio → contrastar con el código → analista funcional (Carabantes) → senior del área (Tomás Soto back, Nicolás front); de código → Tomás Soto → Carabantes si toca negocio → otro. La escalera es del **área** (`refs.yaml`), no del método: las personas son del cliente. Evidencia en TRABAJO: «Para Tomás Carabantes (derivada por Thomas)».
  - **Decidido 2026-10-17 (FASE 9):** complemento = nodo DUDA/TAREA/DAILY_ITEM con etiqueta `complemento:<tipo>` y `PERTENECE_A` su PBI, sin migración; catálogo en `roles.yaml` del área; escalera en `refs.yaml` del área (escalar = mover el `ESPERA_RESPUESTA_DE` a la persona siguiente, rastro en la descripción); decidir = cerrar la duda y dejar un nodo decisión; «para decir» cuelga de un ritual; PBI borrador = HISTORIA sin externo.
  - **PBI sin número = PBI borrador** (nodo HISTORIA sin número ni FASE); las tareas sueltas y las piezas del Draft se cuelgan de él. Las subtareas «falta URL commit y Evidencias» no se crean a mano: salen de las casillas abiertas de `## Cierre oficial` de cada FASE.
  - **Hecho 2026-10-17 (en Changes de `dotfiles`, sin commit):** `workspace-template/docs/roles.yaml` con los 6 roles (marca `**Tipo**`, grupos de `## Tareas`, casillas de `## QA`, columnas y la regla para derivar la etapa) y `docs/backlog/plantillas/plantilla-<rol>.md` (no `FASE_*.md`: los hooks las tratarían como FASE reales). `nuevo-workspace` las copia a cada área: cada empresa ajusta sus roles. `tests/test_roles.sh` valida rol ↔ plantilla, derivación (vacía → primera etapa, llena → cerrado) y su caso rojo. **Paridad 42/42**: la derivación de `roles.yaml` da la misma etapa que `importar:fases` en las 35 FASE del Laboratorio y las 7 de este proyecto. Freddy aceptó que viva en `dotfiles`. **FASE 8 (2026-10-17, sin commit): ya lo leen** `importar:fases` (port de `test_roles.py`, paridad TS = Python 43/43), la API (`GET /roles`, `GET /nodos?rol=`, y `GET /etapas` = lista del tablero **∪** columnas de los roles — no solo la unión: las tarjetas de Todoist usan `❓ DUDAS EN ESPERA` y `🔎 Precheck`, que ningún rol tiene) y la PWA (pestañas Todo + un rol, tareas y FASE, las FASE en solo lectura por D10). Falta: los complementos.
  - **Ideas «a pedido», para DESPUÉS de la base (Freddy, 2026-10-17):** (1) el parte del día para Fabián (terminé / queda / detenido) leído del grafo, sin botón de WhatsApp todavía; (2) revisar en Azure qué tasks propias no tienen URL commit o evidencias y dejarlo como tarjeta de trámites (la lógica ya existe en `bin/fases`); (3) mostrar con claridad las dos tarjetas en curso y si alguna está bloqueada (Freddy trabaja dos a la vez a propósito: no se limita a una). Lo que Fabián le pidió sobre el proceso se junta con `/flow:observaciones` y el complemento «para decir» colgado del 1:1 con Fabián. Contexto: memoria `project-evaluacion1-fabian`.

- **C10 — resuelto para el SAG (2026-10-17, FASE 11):** `importar:fases --proyecto laboratorio --adoptar todoist` hace que la «FASE n» de Todoist sea la del `.md` (TRABAJO es el SAG): mismo nodo, sus conexiones, sin duplicar; por externo, nunca por título. Las de este orquestador son `fases-md:grafo-tareas`. Lo de abajo queda como historia.
- **C10 (2026-10-17, abierto):** el grafo guarda FASEs de varios orquestadores (SAG vía Todoist, grafo-tareas vía `FASE_*.md`) y «FASE n» se repite. Propuesta: una RAMA (o nodo PROYECTO) por orquestador, FASE `PERTENECE_A` ella, y los importadores/el adaptador buscan dentro de la rama. Mientras tanto nada adopta por título y conviven dos «FASE 6».

- **C1 (código) — ✅ CONFIRMADO por Freddy 2026-10-16:** decidí que "bloqueado / libera" se calcula en la API (`WITH RECURSIVE` sobre `Conexion`) y los fronts solo lo reciben, porque con tres repos una regla duplicada se desincroniza · ¿confirmás?
- **C2 (código) — ✅ CONFIRMADO por Freddy 2026-10-16:** decidí guardar `posicion {x,y,z}` en `Nodo` para que el mapa 3D sea estable entre sesiones · ¿confirmás?
- **C3 (código) — ✅ CONFIRMADO por Freddy 2026-10-16:** decidí que todo importador sea idempotente por `externo { origen, id }`, no por título · ¿confirmás?

- **C4 (código) — ✅ HECHO 2026-10-16 (nuevo-workspace → new-project sobre el mismo padre):** orden `nuevo-workspace` → `new-project` sobre el mismo padre, ver § Cómo se crea el proyecto · ¿confirmás?
- **N2 (negocio, Freddy) — ✅ DECIDIDO 2026-10-16: en la FASE 3 entra SOLO `TRABAJO`** (ni el Draft, ni Crecimiento Profesional, ni Mis Proyectos; se suman después si hacen falta). Lo original: alcance del reemplazo. El grafo cubre trabajo y proyectos (laborales, freelance, personales, de aprendizaje). Decidí dejar fuera `RUTINA` (hábitos), `Regalos`, `social` y lo que vive en Reminders (vida diaria): siguen donde están. Confirmar si `🎯 Crecimiento Profesional` (empleo, estudio) entra en F2 o después.
- **N1 (negocio, Freddy) — ✅ DECIDIDO 2026-10-16: nombres reales** de las personas, tal cual están en Todoist (que ya es un tercero); base local en Docker por ahora, y antes de subir a Neon se revisa de nuevo. Lo original: HU, dudas y nombres de personas del cliente (SIIGSA/SAG) quedarán en Neon, un tercero. Decidí seguir porque es Postgres cifrado en tránsito y uso personal; confirmar contra las reglas de confidencialidad del cliente antes de importar datos reales. Default si no: anonimizar nombres de personas en el importador.

## Prompt para retomar (pegarlo tal cual en una sesión nueva o después de /compact)

```text
Retomamos grafo-tareas y el método portable (ignorar lo de juegos del Quest). Antes de hacer nada, leé entero
~/Volumes/Extended/github/DEVELOPMENT/grafo-tareas/docs/_CONCEPTO.md (§ Pareto, § Estado — lo del 2026-10-17 —
y § Para confirmar: C10 y C11), después docs/backlog/README.md, FASE_5_ADAPTADOR_GRAFO_Y_CORTE.md (D10 y el plan
del corte) y el CLAUDE.md del orquestador (§ Lo que vive en este orquestador y § Trampas). Esa es la única fuente.

Reglas: no re-decidir nada ya decidido (Stack, C1-C11, D1-D10); si algo choca, lo marco y pregunto. Método:
/work:backlog:next → /work:backlog:review → /work:sellar:run; commits los corre Freddy salvo «hazlo»; pushear es
publicar → preguntar. Instaladores → confirmar. Reglas globales (~/.claude/CLAUDE.md): sin let, sin any, SSOT,
read-before-write, todo chequeo tiene que poder fallar. pnpm = npx -y pnpm@10.34.7. Bash para scripts (zsh no
parte variables). Nunca pkill -f.

Estado (2026-10-17, tarde-noche): FASE 1-4, 6-11 ✅, FASE 12 (despliegue) 4/5, FASE 5 2/3. Todo pusheado.
**Producción en el Mac Mini (FASE 12):** PWA https://mac-mini-server.tail1798c7.ts.net:10000 · API :8443, Postgres en
Docker (no Neon: Freddy 2026-10-17), datos del PC migrados (214 · 137), respaldo diario en ~/apps/grafo-tareas/deploy/
respaldos. ESA es la base de verdad; la del PC (bin/dev, bin/servir-tailnet) es de desarrollo. Desplegar = pushear +
bin/desplegar (idempotente; dónde corre = refs.yaml → despliegue). ~/bin/claude-bifurcar sin commitear (Freddy:
«olvídate de bifurcar»); dotfiles claude/metodo.md y claude/settings.json NO son míos.

Siguiente, en orden:
1. El corte (FASE 5 tarea 2, Freddy: «después del deploy» → ya se puede): tablero.kind: grafo con api = despliegue.api +
   /api/v1, en este orquestador y en el Laboratorio (con su bloque escalera), según el plan de FASE_5 (D10).
2. Lo de Freddy: abrir la PWA del Mac Mini en el teléfono e instalarla (FASE 12 c1), 2 monitores en Uptime Kuma
   (FASE 12 t5, pide su contraseña), FPS en el visor (FASE 6-7: bin/probar-en-visor --api --abrir), usar la PWA una
   semana (FASE 4 c1), tildar «Listo para PR» en las FASE 23-30 del Laboratorio.
Abierto con Freddy: C10, si «funcional» es el nombre oficial de Producto, Neon (N1), instalador de un comando para el
método (y probarlo en Mac/WSL), detectar el PR desde Azure.
Contexto personal: memoria project-evaluacion1-fabian (evaluación 2 ~22-24 oct → indefinido).
```
