# FASE 22: ESPACIOS, PROYECTOS Y TIPOS COMO DATOS (la API como base)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking: tildar cada paso al cumplirlo, en este archivo.

**Destraba**: que el grafo deje de ser solo el trabajo de SIGSA y crezca a Mis máquinas, conocimiento y lo que venga
**sin una migración nueva por cada uso**: espacio → proyecto → nodos, con los tipos de nodo y de conexión como datos.
**Estado**: implementada en la API (2026-11-13), sin commitear; falta tu revisión y el despliegue. Línea base antes de empezar: unit 147/147 (23 suites), e2e 64/64 (10 suites, el plan decía 11), lint y type-check limpios. Reemplaza la propuesta del 24-10 (un campo `espacio` de texto).
**Azure**: no aplica (tracker: none)
**Tipo**: producto
**Dependencias**: ninguna. La FASE 23 no se toca.
**Fuente**: Freddy, conversación del 2026-11-12/13 («la forma correcta y duradera hacia el futuro»).
**Spec**: `docs/superpowers/specs/2026-11-12-espacios-proyectos-design.md` — leerlo entero antes de empezar (§5, §5b, §6
y §9 sobre todo). Si el spec y este plan se contradicen, **parar y preguntar**: no elegir.

**Goal:** la API admite espacios y proyectos creados por API, tipos de nodo por espacio y tipos de conexión con sus
propiedades en la base, y el método de trabajo (HU, FASE, día, piezas, roles) como una capa que se enciende por espacio.

**Architecture:** el tipo de un nodo y de una conexión pasa de enum de Prisma a **texto validado contra una tabla**
(`TipoNodo` por espacio, `TipoConexion` global). El código del método sigue comparando contra los mismos nombres
(`'TAREA'`), ahora desde constantes propias (Tarea 3), así su comportamiento no cambia. Lo genérico ("hoy puedo",
bloqueado, libera, familia) lee las propiedades de la tabla (`accionable`, `bloquea`, `contiene`). Todo nodo cuelga de
un proyecto; sin `proyectoId` la API usa el proyecto por defecto y lo avisa.

**Tech Stack:** NestJS 11 + Fastify, Prisma 7 + PostgreSQL 16, class-validator, Jest (unit `src/**/*.spec.ts`, e2e
`test/*.e2e-spec.ts`), pnpm 10.

## Restricciones globales (valen para todas las tareas)

- **Solo `grafo-tareas.api`.** La web y la VR (pestañas de espacio, variante A) son la FASE 24; Mis máquinas, la FASE 25.
  En `grafo-tareas.web/` y `grafo-tareas.vr/` solo se regenera el cliente Orval (Tarea 9) y se verifica que compilen.
- **Producción no se toca.** Prohibido: `bin/desplegar`, `bin/importar-en-produccion`, escribir en la API o la base del Mac
  Mini. Lo único permitido allá es **copiar** un respaldo (`scp`, Tarea 10).
- **Migraciones solo en local** (Freddy las autorizó el 2026-11-13 al pedir la implementación):
  - base de desarrollo: `postgresql://grafo:grafo@localhost:5433/grafo_tareas` (contenedor `grafo-tareas-postgres`, ya arriba);
  - base de e2e: la misma URL terminada en `_test`. Antes de `pnpm test:e2e`, siempre:
    `DATABASE_URL=postgresql://grafo:grafo@localhost:5433/grafo_tareas_test?schema=public pnpm prisma migrate deploy`.
- **Sin commits, sin ramas, sin push.** Los commits los hace Freddy (regla global §1). Al final de cada tarea, en vez de
  commit, la **verificación completa** en `grafo-tareas.api`: `pnpm lint && pnpm type-check && pnpm test` y, con la base
  `_test` migrada, `pnpm test:e2e`. Todo verde, y se anota en el paso el total de tests (denominador: regla global §12).
- **TDD:** cada test nuevo se ve fallar antes de implementar; se anota en el paso el mensaje de la falla.
- **Sin `let`**, tampoco en specs: unit con `const armar = async () => …compile()`; e2e con `const ctx = {} as {…}`.
- **La API no nombra herramientas**: el CI busca `todoist` en minúscula, en código y comentarios.
- **Constantes con nombre** en `src/common/constants/` (regla global §2). Nada de strings sueltos `'trabajo-hu'`.
- **Patrón de módulo:** como `src/modules/ramas/`: `*.module.ts`, `*.controller.ts`, `*.service.ts`, `*.repository.ts`
  (clase `@Injectable()` que recibe `PrismaService`; no extiende nada), `dto/` con class-validator y barrel `index.ts`.
  Las respuestas salen envueltas por el `ResponseInterceptor` (`{ statusCode, data, meta }`).
- **Trampas que muerden acá** (leer `CLAUDE.md` del orquestador, §Trampas): Prisma 7 sin `migrate diff --from-url`; los e2e
  vacían su base en `beforeAll`; no correr `pnpm build` de la API con `bin/dev` andando; **nunca `pnpm build` en
  `grafo-tareas.vr`** (reescribe `dist/`, que es lo que sirve el visor); CORS ya permite `PATCH`/`DELETE`.
- **Si algo falla dos veces igual, parar** y releer los archivos involucrados desde cero (regla global §0.1). Si después
  sigue sin salir, dejar el paso sin tildar con una nota `> BLOQUEADO: …` y seguir con lo que no dependa de él.

## Review Focus (lo que ningún test de tarea cubre por sí solo y más puede morder)

1. Un adaptador viejo crea un nodo **sin `proyectoId`**: tiene que caer en SAG con el header `X-Aviso-Proyecto: por-defecto`,
   nunca un 500 → caso en Tarea 5.
2. **Mover un nodo** a un proyecto de otro espacio donde su tipo no existe: 409 con el nombre del tipo, sin mover → Tarea 5.
3. Un tipo **sin ciclo**: `estado` queda `null` aunque el cliente mande `ABIERTO`, y "hoy puedo" no lo lista → Tareas 5 y 6.
4. **Lo archivado**: sale de `GET /espacios` y de "hoy puedo", pero `GET /nodos?q=` lo encuentra, y un `BLOQUEADA_POR`
   hacia algo archivado **sigue bloqueando** → Tarea 6.
5. **El método SIGSA no cambia de comportamiento**: los unit y e2e de hoy siguen verdes sin tocar ningún assert (solo
   imports y la siembra) → Tareas 3, 6 y 7; y el ensayo con datos reales → Tarea 10.

---

### Tarea 1: Esquema — espacios, proyectos, tablas de tipos, tipo como texto

**Files:**
- Modify: `grafo-tareas.api/prisma/schema.prisma`
- Create: `grafo-tareas.api/prisma/migrations/20261113000000_espacios/migration.sql`

**Produces:**
- `model Espacio { id String @id @default(uuid()); nombre String @unique; color String?; orden Int @default(0); archivado Boolean @default(false); metodo String?; etapas String[] @default([]); createdAt DateTime @default(now()) @map("created_at"); proyectos Proyecto[]; tiposNodo TipoNodo[]; @@map("espacios") }`
- `model Proyecto { id (uuid); espacioId String @map("espacio_id"); nombre String; color String?; orden Int @default(0); archivado Boolean @default(false); createdAt; espacio Espacio @relation(onDelete: Restrict); nodos Nodo[]; @@unique([espacioId, nombre]); @@map("proyectos") }`
- `model TipoNodo { id (uuid); espacioId; nombre String; color String?; forma String?; tieneCiclo Boolean @default(true) @map("tiene_ciclo"); accionable Boolean @default(false); espacio Espacio @relation(onDelete: Cascade); @@unique([espacioId, nombre]); @@map("tipos_nodo") }`
- `model TipoConexion { id (uuid); nombre String @unique; bloquea Boolean @default(false); contiene Boolean @default(false); simetrica Boolean @default(false); @@map("tipos_conexion") }` — **global**, sin espacio.
- `Nodo.tipo String` (era enum) · `Nodo.estado EstadoNodo? @default(ABIERTO)` (opcional, **conserva el default**: sin él, los tests de hoy cambiarían de comportamiento; el `null` de los tipos sin ciclo lo pone el servicio en la Tarea 5) · `Nodo.proyectoId String? @map("proyecto_id")` + relación a `Proyecto` + `@@index([proyectoId])`. El `@@index([tipo, estado])` se conserva.
- `Conexion.tipo String` (era enum).
- Se borran del schema `enum TipoNodo` y `enum TipoConexion`. Quedan `EstadoNodo`, `Cara` y `TipoCambio`.

- [x] **Paso 1:** editar `schema.prisma` con lo de arriba.
- [x] **Paso 2:** `pnpm prisma migrate dev --create-only --name espacios`. Revisar el SQL a mano: las columnas `tipo` se
  convierten con `ALTER TABLE … ALTER COLUMN "tipo" TYPE TEXT USING "tipo"::text` (si Prisma generó drop + add, reescribirlo:
  no se pierde ningún dato); `estado` pierde `NOT NULL` y conserva su `DEFAULT 'ABIERTO'`; los `DROP TYPE` de los dos enums van al final.
- [x] **Paso 3:** `pnpm prisma migrate dev` (aplica en `grafo_tareas` local). Verificar: `SELECT count(*) FROM nodos` igual que antes. *(225 antes y después; `migrate diff` = «No difference detected».)*
- [x] **Paso 4:** `pnpm type-check` **falla** por los imports de `TipoNodo`/`TipoConexion` desde `@prisma/client`: es lo
  esperado, lo arregla la Tarea 3. Anotar la cantidad de errores. *(337 errores TS tras `prisma generate`.)*

### Tarea 2: Datos — SIGSA, SAG y los tipos de hoy como filas (migraciones aparte)

**Files:**
- Create: `grafo-tareas.api/prisma/migrations/20261113000100_espacios_datos/migration.sql`
- Create: `grafo-tareas.api/test/fixtures/sembrar-espacio.ts`
- Modify: los 11 `grafo-tareas.api/test/*.e2e-spec.ts` (limpieza + siembra)

**Produces:**
- Migración de datos, SQL idempotente (`INSERT … ON CONFLICT DO NOTHING`, ids con `gen_random_uuid()`):
  - `tipos_conexion`: `DEPENDE_DE`, `ESPERA_RESPUESTA_DE`, `BLOQUEADA_POR` con `bloquea=true`; `PERTENECE_A` con
    `contiene=true`; `EN_DAILY_DE`; `SE_RELACIONA_CON` con `simetrica=true`; `DERIVA_DE`.
  - Espacio `SIGSA` con `metodo='trabajo-hu'` y `etapas` = las 14 de `ETAPAS_POR_DEFECTO`
    (`src/common/constants/grafo.constants.ts:50-65`, copiadas tal cual, con sus emojis); proyectos `SAG` y `General`.
  - `tipos_nodo` de SIGSA: `TAREA` (`accionable=true`), `HISTORIA`, `FASE`, `RAMA`, `DUDA`, `PERSONA`, `PR`, `DAILY_ITEM`,
    todos `tiene_ciclo=true`.
  - `UPDATE nodos SET proyecto_id = (SELECT id FROM proyectos WHERE nombre='SAG') WHERE proyecto_id IS NULL;`
- `proyecto_id` sigue **opcional** hasta la Tarea 5: obligarlo antes rompe los e2e de la Tarea 3, que crean nodos sin
  proyecto y la API todavía no sabe elegir el de por defecto.
- `export async function sembrarEspacioTrabajo(prisma: PrismaService): Promise<{ espacioId: string; proyectoSagId: string; proyectoGeneralId: string }>`
  crea exactamente lo mismo que la migración de datos (los e2e vacían su base y la siembra se pierde).
- `export async function vaciarBase(prisma: PrismaService): Promise<void>` en el mismo archivo: borra en orden hijos →
  padres (`conexion`, `nodo`, `descarte`, `cambio`, `tipoNodo`, `proyecto`, `espacio`, `tipoConexion`). Los 11 e2e
  reemplazan sus `deleteMany` por `await vaciarBase(ctx.prisma); await sembrarEspacioTrabajo(ctx.prisma);`.

- [x] **Paso 1:** escribir la migración de datos; `pnpm prisma migrate dev`; verificar `SELECT count(*) FROM nodos WHERE proyecto_id IS NULL` = 0 y `SELECT count(*) FROM tipos_conexion` = 7. *(medido: 0 sin proyecto, 7 tipos de conexión, 8 tipos de nodo, 14 etapas, 2 proyectos.)*
- [x] **Paso 2:** escribir `sembrar-espacio.ts` y cambiar la limpieza de los 11 e2e *(son 9 los que vacían la base; `app.e2e-spec.ts` y el resto no)* (sin tocar ningún otro assert).
  Todavía no corren: dependen de la Tarea 3.

### Tarea 3: Constantes de tipos en lugar de los enums de Prisma (refactor sin cambio de comportamiento)

**Files:**
- Create: `grafo-tareas.api/src/common/constants/tipos.constants.ts` (exportado desde `src/common/constants/index.ts`)
- Modify: todo archivo de `src/` y `test/` que importe `TipoNodo` o `TipoConexion` de `@prisma/client`
  (`grep -rl "TipoNodo\|TipoConexion" src test`: ~36 archivos, ~272 usos)

**Produces:**
- `export const TIPO_NODO = { TAREA: 'TAREA', HISTORIA: 'HISTORIA', FASE: 'FASE', RAMA: 'RAMA', DUDA: 'DUDA', PERSONA: 'PERSONA', PR: 'PR', DAILY_ITEM: 'DAILY_ITEM' } as const;`
- `export const TIPO_CONEXION = { DEPENDE_DE: 'DEPENDE_DE', ESPERA_RESPUESTA_DE: 'ESPERA_RESPUESTA_DE', BLOQUEADA_POR: 'BLOQUEADA_POR', PERTENECE_A: 'PERTENECE_A', EN_DAILY_DE: 'EN_DAILY_DE', SE_RELACIONA_CON: 'SE_RELACIONA_CON', DERIVA_DE: 'DERIVA_DE' } as const;`
- `export type NombreTipoNodoMetodo = (typeof TIPO_NODO)[keyof typeof TIPO_NODO];` (y el análogo para conexiones)
- `export const METODO_TRABAJO_HU = 'trabajo-hu';` · `export const NOMBRE_PROYECTO_GENERAL = 'General';` · `export const NOMBRE_PROYECTO_POR_DEFECTO = 'SAG';`
- Reemplazo mecánico `TipoNodo.X` → `TIPO_NODO.X`, `TipoConexion.X` → `TIPO_CONEXION.X`. Donde el enum era un **tipo**
  (parámetros, interfaces como `FiltroNodos.tipo`), pasa a `string`. Los `@IsEnum(TipoNodo|TipoConexion)` de
  `nodos/dto/create-nodo.dto.ts:27`, `nodos/dto/listar-nodos.dto.ts:21`, `conexiones/dto/create-conexion.dto.ts:21` y
  `conexiones/dto/listar-conexiones.dto.ts:16` pasan a `@IsString() @IsNotEmpty()`: la validación real contra la tabla es de
  las Tareas 5 y 6. Los decoradores `@ApiProperty({ enum: … })` pasan a `type: String`.

- [x] **Paso 1:** reemplazo; `pnpm type-check` sin errores. *(0 errores; 47 archivos. Desvío: el `estado` opcional y `proyectoId` del esquema obligaron a tipar `estado: EstadoNodo | null` en `calcular-paginas`, `calcular-tablero-plan`, `NodoResponseDto`, `RamaResponseDto`, y a sumar `proyectoId` + `estado` nulo a `pulido/archivo.ts`.)*
- [x] **Paso 2:** `pnpm test` → verde con el mismo total que antes (147), **sin cambiar ningún assert**. *(147/147, 23 suites; solo se agregó `proyectoId: null` al fixture de `archivo.spec.ts`.)*
- [x] **Paso 3:** migrar la base `_test` (comando de las Restricciones) y `pnpm test:e2e` → verde. *(64/64, 10 suites.)* Si un assert tiene que
  cambiar para pasar, parar: es un cambio de comportamiento, no un refactor; anotarlo como bloqueo.

### Tarea 4: Módulos `espacios`, `proyectos` y `tipos`

**Files:**
- Create: `src/modules/espacios/` — `espacios.module.ts`, `espacios.controller.ts`, `espacios.service.ts`, `espacios.repository.ts`, `plantillas.ts`, `dto/{create-espacio,update-espacio,espacio-response,listar-espacios}.dto.ts`, `dto/index.ts`
- Create: `src/modules/proyectos/` — mismo patrón (`create-proyecto`, `update-proyecto`, `proyecto-response`)
- Create: `src/modules/tipos/` — mismo patrón (`create-tipo-nodo`, `update-tipo-nodo`, `create-tipo-conexion`, respuestas)
- Modify: `src/app.module.ts`
- Test: `src/modules/espacios/plantillas.spec.ts`, `test/espacios.e2e-spec.ts` (nuevo, usa `vaciarBase` + `sembrarEspacioTrabajo`)

**Produces (todo bajo `/api/v1`):**
- `GET /espacios?archivados=false|true` (default `false`) → `EspacioResponse[]` ordenados por `orden`, `nombre`.
- `POST /espacios { nombre, color?, plantilla: 'empresa'|'maquinas'|'conocimiento'|'vacia' }` → 201 `EspacioResponse`. En una
  sola transacción: el espacio, su proyecto `General` y los tipos y etapas de la plantilla. Nombre repetido → 409.
  `metodo` **no** se elige por API: solo SIGSA lo tiene, por migración.
- `PATCH /espacios/:id { nombre?, color?, orden?, archivado? }` · `DELETE /espacios/:id` → 409 si alguno de sus proyectos tiene nodos.
- `GET /espacios/:id/proyectos?archivados=` · `POST /espacios/:id/proyectos { nombre, color? }` (409 si repite nombre en el
  espacio) · `PATCH /proyectos/:id { nombre?, color?, orden?, archivado? }` · `DELETE /proyectos/:id` → 409 si tiene nodos.
- `GET /espacios/:id/tipos-nodo` (por `nombre`) · `POST /espacios/:id/tipos-nodo { nombre, color?, forma?, tieneCiclo?, accionable? }` · `PATCH /tipos-nodo/:id { color?, forma?, tieneCiclo?, accionable? }` (el nombre no se edita en esta FASE) ·
  `GET /tipos-conexion` · `POST /tipos-conexion { nombre, bloquea?, contiene?, simetrica? }`.
- `EspacioResponse { id, nombre, color, orden, archivado, metodo: string | null, etapas: string[] }` ·
  `ProyectoResponse { id, espacioId, nombre, color, orden, archivado }` ·
  `TipoNodoResponse { id, espacioId, nombre, color, forma, tieneCiclo, accionable }` ·
  `TipoConexionResponse { id, nombre, bloquea, contiene, simetrica }`.
- `plantillas.ts`: `export type NombrePlantilla = 'empresa' | 'maquinas' | 'conocimiento' | 'vacia';` y
  `export const PLANTILLAS: Readonly<Record<NombrePlantilla, { tiposNodo: readonly { nombre: string; tieneCiclo: boolean; accionable: boolean }[]; etapas: readonly string[] }>>` con:
  - `empresa`: `TAREA` (ciclo, accionable), `DUDA` (ciclo), `PERSONA` (ciclo) · etapas `['Pendiente', 'Haciendo', 'Hecho']`
  - `maquinas`: `MAQUINA`, `FAMILIA`, `HERRAMIENTA`, los tres sin ciclo ni accionable · etapas `[]`
  - `conocimiento`: `CONCEPTO`, `IDEA`, sin ciclo ni accionable · etapas `[]`
  - `vacia`: sin tipos · etapas `[]`

- [x] **Paso 1 (rojo):** `plantillas.spec.ts` — `it('maquinas no tiene tipos con ciclo')` (todos `tieneCiclo === false`);
  `it('empresa marca solo TAREA como accionable')`; `it('empresa trae las etapas Pendiente, Haciendo, Hecho')`. *(rojo visto: «Cannot find module './plantillas'» (3 tests, 0 corridos))*
- [x] **Paso 2 (rojo):** `espacios.e2e-spec.ts`:
  - `POST /espacios {nombre:'Mis máquinas', plantilla:'maquinas'}` → 201; `GET /espacios/:id/proyectos` → nombres exactamente `['General']`; `GET /espacios/:id/tipos-nodo` → nombres `['FAMILIA','HERRAMIENTA','MAQUINA']`.
  - mismo nombre otra vez → 409.
  - `PATCH {archivado:true}` → ya no está en `GET /espacios`; sí en `GET /espacios?archivados=true`.
  - `POST /espacios/:id/proyectos {nombre:'ThinkPad'}` → 201; repetido → 409.
  - `DELETE /proyectos/:id` del SAG sembrado con un nodo adentro → 409; de un proyecto vacío → 200.
  - `POST /tipos-conexion {nombre:'BLOQUEADA_POR'}` → 409 (ya existe). *(rojo visto: 6 de 6 fallaban con Expected 201/409 · Received 404)*
- [x] **Paso 3:** implementar. **Paso 4:** verificación completa verde (anotar totales). *(verde: lint y type-check 0 errores; unit 150/150 (24 suites); e2e 70/70 (11 suites). DELETE devuelve 200 con la entidad borrada, como pide el plan)*

### Tarea 5: Nodos con proyecto y tipo validado

**Files:**
- Modify: `src/modules/nodos/dto/{create-nodo,update-nodo,listar-nodos,nodo-response}.dto.ts`
- Modify: `src/modules/nodos/nodos.service.ts`, `nodos.repository.ts` (`FiltroNodos`, `whereDe`), `nodos.controller.ts`
- Create: `src/modules/nodos/proyecto-por-defecto.service.ts` (provider de `NodosModule`, exportado)
- Create: `grafo-tareas.api/prisma/migrations/20261113000200_proyecto_obligatorio/migration.sql` (`proyecto_id SET NOT NULL`; en el schema, `proyectoId String` obligatorio)
- Modify: `src/config/env.constants.ts` (`PROYECTO_POR_DEFECTO: 'PROYECTO_POR_DEFECTO'`)
- Modify: `src/common/constants/` (`HEADER_AVISO_PROYECTO = 'X-Aviso-Proyecto'`, `AVISO_PROYECTO_POR_DEFECTO = 'por-defecto'`)
- Test: `src/modules/nodos/proyecto-por-defecto.service.spec.ts`, `test/espacios.e2e-spec.ts`

**Produces:**
- `CreateNodoDto.proyectoId?: string` (`@IsUUID()`), `UpdateNodoDto.proyectoId?: string`, `NodoResponse.proyectoId: string`.
- `ProyectoPorDefectoService.resolver(proyectoId?: string): Promise<{ proyectoId: string; porDefecto: boolean }>`:
  con id → valida que exista (404 si no) y `porDefecto: false`. Sin id → el de la variable `PROYECTO_POR_DEFECTO` si existe
  en la base; si no, el proyecto `NOMBRE_PROYECTO_POR_DEFECTO` del espacio cuyo `metodo = METODO_TRABAJO_HU`; si tampoco
  existe → 400 `«falta proyectoId y no hay proyecto por defecto»`. `porDefecto: true`.
- `POST /nodos` sin `proyectoId` responde con el header `X-Aviso-Proyecto: por-defecto` (en el controlador, con la respuesta
  de Fastify; el cuerpo no cambia de forma).
- Validación de `tipo` al crear y al mover: debe existir en `tipos_nodo` del espacio del proyecto; si no → 400
  `` `tipo «${tipo}» no existe en el espacio «${espacio}»` `` (al mover, 409 con el mismo texto).
- Si el tipo tiene `tieneCiclo=false` → `estado` se guarda `null` (se ignora lo que mande el cliente); con ciclo y sin
  `estado` en el cuerpo → `ABIERTO` (el default que antes ponía la base).
- `PATCH /nodos/:id { proyectoId }` mueve el nodo; queda en la bitácora como cualquier edición (`Cambio`, `campo='proyectoId'`).
- `FiltroNodos` suma `proyectoId?: string` y `espacioId?: string`; `GET /nodos?proyecto=<id>&espacio=<id>`. Sin ellos, todos
  los espacios, archivados incluidos (así `?q=` encuentra todo, spec §2.6).

- [x] **Paso 1 (rojo):** unit `proyecto-por-defecto.service.spec.ts` — sin variable de entorno y con un SAG en el repo
  falso → `{ proyectoId: <SAG>, porDefecto: true }`; con la variable apuntando a un id inexistente → cae al SAG; sin nada → 400. *(rojo visto: «Cannot find module './proyecto-por-defecto.service'»)*
- [x] **Paso 2 (rojo):** e2e en `espacios.e2e-spec.ts`:
  - `POST /nodos {tipo:'TAREA', titulo:'sin proyecto'}` → 201, header `x-aviso-proyecto: por-defecto`, `proyectoId` = SAG sembrado.
  - `POST /nodos {tipo:'MAQUINA', titulo:'x', proyectoId:<General de SIGSA>}` → 400 con `MAQUINA` en el mensaje.
  - en Mis máquinas: `POST /nodos {tipo:'HERRAMIENTA', titulo:'buildworkspace', estado:'ABIERTO', proyectoId:<General>}` → 201 y `estado: null`.
  - `PATCH /nodos/<una TAREA de SAG> {proyectoId:<General de Mis máquinas>}` → 409 y el nodo sigue en SAG.
  - un nodo en un espacio archivado: `GET /nodos?q=<su título único>` lo devuelve; `GET /nodos?espacio=<SIGSA>` no. *(rojo visto: los 5 casos nuevos fallaban (400 por «proyectoId should not exist»))*
- [x] **Paso 3:** implementar el servicio, el header y la validación; recién entonces la migración `proyecto_obligatorio` (`pnpm prisma migrate dev`, y `migrate deploy` en la `_test`). *(DESVÍO: la migración `proyecto_obligatorio` NO se aplicó acá. Hay ~20 escritores de nodos sin proyecto (importadores, piezas, complementos, restaurar descarte) y ~22 fixtures de e2e que crean nodos con Prisma; los arreglan las Tareas 7 y 8. Se aplica al final de la Tarea 8 (Paso 3b), para que cada tarea cierre en verde)*
- [x] **Paso 4:** verificación completa verde. *(verde: lint y type-check 0 errores; unit 153/153 (25 suites); e2e 75/75 (11 suites))*

### Tarea 6: Derivados genéricos desde las propiedades de los tipos

**Files:**
- Create: `src/modules/tipos/tipos-propiedades.service.ts` (exportado por `TiposModule`)
- Modify: `src/modules/derivado/derivado.repository.ts` (`BLOQUEA_AHORA` pasa a ser una función, `hoyPuedo`, `bloqueadoresDe`), `derivado.service.ts`, `derivado.controller.ts`, `derivado.module.ts`
- Modify: `src/modules/derivado/calcular-libera.ts`, `calcular-familia.ts` solo si leen las constantes borradas
- Modify: `src/common/constants/grafo.constants.ts` — borrar `CONEXIONES_BLOQUEANTES` y `TIPOS_ACCIONABLES` (su lugar es la tabla); grep que no quede ningún uso
- Test: `src/modules/derivado/derivado.service.spec.ts`, `test/espacios.e2e-spec.ts`

**Produces:**
- `TiposPropiedadesService.bloqueantes(): Promise<readonly string[]>` (nombres con `bloquea=true`) ·
  `.contenedoras(): Promise<readonly string[]>` (`contiene=true`) ·
  `.accionables(): Promise<readonly { espacioId: string; nombre: string }[]>` (`accionable=true`). Sin caché entre
  requests (la tabla es chica; YAGNI).
- `bloqueaAhora(bloqueantes: readonly string[]): Prisma.ConexionWhereInput` reemplaza la constante `BLOQUEA_AHORA`
  (`derivado.repository.ts:43`) con la misma excepción de `DEPENDE_DE` hacia lo mergeado (`ETIQUETA_MERGEADA`,
  `ETAPA_MERGEADA`): esa regla es del método y no se toca.
- `GET /derivado/hoy-puedo?proyecto=&espacio=` → nodos cuyo par (espacio del proyecto, tipo) está en `accionables()`,
  `estado ABIERTO`, sin bloqueo vivo, y con proyecto **y** espacio no archivados. Sin parámetros: todos los espacios no archivados.
- `GET /nodos/:id/bloqueado`, `/libera`, `/familia`: con `bloqueantes()` / `contenedoras()`; cruzan proyectos y espacios,
  archivados incluidos (un bloqueo es un hecho, spec §5).

- `GET /proyectos/:id/vecinos` → `NodoResponse[]` de los nodos de **otros** proyectos conectados (en cualquier dirección)
  con algún nodo del proyecto, cada uno con su `proyectoId`. Es lo que la FASE 24 pinta como "fantasma" (spec §5).

- [x] **Paso 1 (rojo):** e2e:
  - una `HERRAMIENTA` de Mis máquinas conectada con `SE_RELACIONA_CON` a una `TAREA` de SAG: `GET /proyectos/<SAG>/vecinos` la trae, y no trae ningún nodo de SAG.
  - una `HERRAMIENTA` de Mis máquinas no aparece en `hoy-puedo`.
  - una `TAREA` de un espacio `empresa` archivado no aparece; la misma, con el espacio sin archivar, sí.
  - una `TAREA` de SAG con `BLOQUEADA_POR` hacia una `TAREA` ABIERTA de un espacio archivado → `bloqueado: true`.
  - `hoy-puedo?espacio=<SIGSA>` no trae nodos de otro espacio. *(rojo visto: 3 de los 5 casos fallaban (vecinos: Expected 200 Received 404; las dos TAREA de espacios archivados/otro espacio aparecían en hoy puedo). Los otros 2 ya pasaban: son los que fijan lo que NO debe cambiar (HERRAMIENTA fuera de hoy puedo; bloqueo hacia lo archivado sigue bloqueando))*
- [x] **Paso 2:** implementar. **Paso 3:** verificación completa verde; los specs de `calcular-*` y los e2e de `grafo`,
  `dia` y `paginas` pasan sin cambiar asserts. *(verde: lint y type-check 0 errores; unit 153/153 (25 suites); e2e 80/80 (11 suites). Desvíos: (a) derivado.service.spec: un assert cambia porque bloqueosDe recibe ahora los tipos bloqueantes como 2.º argumento (firma, no comportamiento); calcular-paginas.spec y derivado.service.spec solo cambian su armado. (b) los escritores de complementos heredan el proyecto de su padre (si no, hoy puedo los excluía) y el fixture de complementos.e2e pasa proyectoId)*

### Tarea 7: La capa del método y las etapas por espacio

**Files:**
- Create: `src/common/decorators/requiere-metodo.decorator.ts` (`@RequiereMetodo(metodo: string)`) y `src/common/guards/requiere-metodo.guard.ts` (+ barrels)
- Modify: controladores de `roles`, `complementos`, `area`, `piezas`, y los endpoints `dia`, `paginas`, `plan` de `derivado.controller.ts`
- Modify: `src/modules/nodos/etapas.service.ts`, `etapas.controller.ts`
- Modify: `src/importadores/todoist/cli.ts`, `src/importadores/fases/cli.ts`, `importador-fases.service.ts`, `importador-todoist.service.ts`, `aplicar-plan.ts`
- Test: `test/espacios.e2e-spec.ts`, specs existentes de importadores

**Produces:**
- El guard lee `?espacio=<id>`; sin él, el espacio del proyecto por defecto (`ProyectoPorDefectoService`). Si ese espacio no
  tiene `metodo === METODO_TRABAJO_HU` → 404 `` `el espacio «${nombre}» no usa el método de trabajo` ``. Con SIGSA, las
  respuestas son idénticas a las de hoy.
- `GET /etapas?espacio=<id>`: para un espacio **con** método, lo de hoy (variable `ETAPAS` o `ETAPAS_POR_DEFECTO`, unidas a
  las columnas de los roles); para uno **sin** método, sus `etapas` de la base. `EtapasService.validar(etapa, espacioId)`
  valida contra la lista de ese espacio.
- Importadores: `--proyecto <uuid>` **obligatorio** en los dos CLI (sin él: error y salida 1, antes de tocar la base). Todo
  nodo que crean lleva ese `proyectoId`, y sus búsquedas por título (`findFirst`, `startsWith` en
  `importador-fases.service.ts:287,339,385,405`) filtran por él.

- [x] **Paso 1 (rojo):** e2e — `GET /derivado/dia?espacio=<Mis máquinas>` → 404; `GET /etapas?espacio=<espacio empresa nuevo>` →
  `['Pendiente','Haciendo','Hecho']`; `GET /roles` y `GET /derivado/dia` sin parámetro → mismas respuestas que antes de la FASE. *(rojo visto: 4 de 5 fallaban (dia?espacio= daba 400 en vez de 404; etapas del espacio nuevo no eran las suyas; etapa ajena aceptada). El de «sin parámetro responde como siempre» ya pasaba: fija lo que no cambia)*
- [x] **Paso 2 (rojo):** unit de importadores — el CLI sin `--proyecto` sale con error antes de leer nada. *(rojo visto: «Cannot find module ./proyecto-grafo». DESVÍO: la bandera es --proyecto-grafo <uuid>, no --proyecto: los dos CLI ya usaban --proyecto con otro sentido (id de Todoist; nombre del orquestador) y bin/importar-en-produccion lo pasa. La lógica está en src/importadores/proyecto-grafo.ts para poder probarla sin process.exit)*
- [x] **Paso 3:** implementar. **Paso 4:** verificación completa verde; los e2e de `dia`, `paginas`, `piezas`,
  `complementos`, `roles`, `importador` e `importador-fases` pasan sin cambiar asserts (salvo pasar `--proyecto`/`proyectoId`). *(verde: lint y type-check 0 errores; unit 157/157 (26 suites); e2e 85/85 (11 suites). Desvíos: EtapasService queda como está y la lista por espacio vive en EtapasDelEspacioService (así roles.service.spec no cambia); MetodoModule global aloja ProyectoPorDefectoService para que el guard lo vea desde cualquier módulo; los e2e de importadores pasan proyectoGrafo/proyectoId, y los de la FASE crean sus nodos de fixture con proyectoId)*

### Tarea 8: Descartes viejos y lo archivado

**Files:**
- Modify: `src/modules/pulido/pulido.repository.ts`, `pulido.service.ts`
- Test: `test/pulido.e2e-spec.ts`

**Produces:**
- Restaurar un `Descarte` cuyo JSON `nodo` no trae `proyectoId` (los de antes de esta FASE) → vuelve con
  `ProyectoPorDefectoService.resolver()`.
- Restaurar a un proyecto archivado → se restaura igual (archivar no es borrar).

- [x] **Paso 1 (rojo):** e2e — insertar con Prisma un `Descarte` con `nodo` JSON sin `proyectoId`; restaurarlo → 201 y `proyectoId` = SAG. *(rojo visto: Expected el uuid del SAG, Received null. El segundo caso (restaurar a un proyecto archivado) ya pasaba: fija que archivar no es borrar)*
- [x] **Paso 2:** implementar. **Paso 3:** verificación completa verde. *(verde: unit 157/157, e2e 87/87. Si el proyecto del archivo ya no existe también cae al de respaldo)*
- [x] **Paso 3b (desvío de la Tarea 5):** con todos los escritores y fixtures pasando `proyectoId`, crear `20261113000200_proyecto_obligatorio` (`proyecto_id SET NOT NULL`; en el schema `proyectoId String` y la relación obligatoria), `migrate dev` y `migrate deploy` en la `_test`, y verificación completa verde. *(aplicada en grafo_tareas y en grafo_tareas_test (esta última había guardado la migración como fallida por 3 nodos de pruebas anteriores sin proyecto: se marcó rolled-back, se vació la base de pruebas y se reaplicó). Verde final: lint y type-check 0 errores; unit 157/157 (26 suites); e2e 87/87 (11 suites))*

### Tarea 9: Contrato, documentación y reglas

**Files:**
- Modify: `grafo-tareas.api/openapi.json` — `pnpm openapi:export` (ya pasa Prettier)
- Modify: clientes generados de `grafo-tareas.web` y `grafo-tareas.vr` — `pnpm api:generar` en cada uno; sin tocar componentes
- Modify: `grafo-tareas/CLAUDE.md` §Trampas (línea 36): reemplazar «El grafo de producción es el trabajo del SAG, nada más»
  por «**Cada mundo es un espacio; nada se mezcla sin espacio** (FASE 22, 2026-11-13). SIGSA es el espacio con el método de
  trabajo; lo demás vive en su propio espacio». Conservar la historia del 2026-10-17 en una línea.
- Modify: `~/.claude/CLAUDE.md` §18, la línea «Lo que una sesión crea en el grafo cuelga de su HU o de su FASE … «Sin HU»»
  → «Lo que una sesión crea en el grafo cuelga de su **proyecto** (y, en un espacio con método de trabajo, de su HU o su
  FASE); suelto cae en el **General** de su espacio». Una línea, sin cambiar el resto de §18.
- Modify: `docs/backlog/README.md` (fila de la FASE 22: título y estado), `docs/_CONCEPTO.md` (§ Modelo de dominio: una línea con puntero al spec)
- Modify: `deploy/compose.yml` — agregar `PROYECTO_POR_DEFECTO: ''` al servicio de la API con un comentario («el id del
  proyecto SAG tras migrar; vacío = lo busca por nombre»).

- [x] **Paso 1:** `pnpm openapi:export` (con `bin/dev` apagado) y `pnpm api:generar` en web y vr. *(openapi.json: 36 rutas. Web con pnpm api:generar; VR con npm run api:generar (la VR usa npm: el primer intento con pnpm instaló por su cuenta y se revirtió, ver CLAUDE.md §Trampas))*
- [x] **Paso 2:** web: `pnpm lint && pnpm exec tsc --noEmit && pnpm test`. vr: `pnpm lint && pnpm exec tsc -p tsconfig.app.json --noEmit && pnpm test`. **No** `pnpm build` en vr.
  Si algún componente deja de compilar por el cambio de tipos (`TipoNodo` enum → `string`), arreglar solo el tipo, no la UI. *(web: lint 0, tsc 0, vitest 41/41 (13 archivos); vr: lint 0, tsc 0, vitest 175/175 (25 archivos); sin build en vr. Arreglos solo de tipos: constantes TipoNodo/TipoConexion locales en web (ya no existen las enums generadas), estado nullable, y en la VR casts en el borde desde-api.ts y la firma de useDerivadoControllerHoyPuedo)*
- [x] **Paso 3:** editar docs y reglas. *(CLAUDE.md §Trampas (+ trampa nueva de npm en la VR), ~/.claude/CLAUDE.md §18 (es un symlink: se editó ~/dotfiles/claude/CLAUDE.md), backlog/README.md, _CONCEPTO.md y deploy/compose.yml)*

### Tarea 10: Ensayo con los datos reales (criterio 1)

**Files:** ninguno del repo. Todo en una base local nueva, `grafo_tareas_copia`.

- [x] **Paso 1:** copiar el último respaldo: `scp mac-mini:apps/grafo-tareas/deploy/respaldos/$(ssh mac-mini 'ls -t ~/apps/grafo-tareas/deploy/respaldos | head -1') /tmp/grafo-copia.dump` (solo lectura del Mac Mini). *(copiado grafo-2026-11-13_1448.dump (solo lectura en el Mac Mini); 311 nodos)*
- [x] **Paso 2:** `docker exec grafo-tareas-postgres createdb -U grafo grafo_tareas_copia` y `pg_restore` del dump ahí (dentro del contenedor o con `docker cp`). *(grafo_tareas_copia creada y restaurada: 311 nodos, esquema en 20261026000000_resumen)*
- [x] **Paso 3 (antes):** levantar la API **de antes de la FASE** contra la copia no es posible (el código ya cambió): en su
  lugar, guardar con SQL la lista de "hoy puedo" de hoy: TAREA, ABIERTO, sin conexión saliente `DEPENDE_DE`/
  `ESPERA_RESPUESTA_DE`/`BLOQUEADA_POR` hacia un destino ABIERTO (con la excepción de lo mergeado de `BLOQUEA_AHORA`).
  Guardar los ids en `/tmp/hoy-puedo-antes.txt` y anotar el total. *(SQL sobre la copia con el esquema viejo: 76 ids de 83 TAREA abiertas, en hoy-puedo-antes.txt (el dump y las listas están en el scratchpad de la sesión, no en /tmp). Hecho fallar: sin la excepción de lo mergeado daría 72)*
- [x] **Paso 4:** `DATABASE_URL=…/grafo_tareas_copia?schema=public pnpm prisma migrate deploy`. Verificar: 0 nodos sin proyecto. *(migrate deploy aplicó las 3 migraciones: 311 nodos, 0 sin proyecto, los 311 en SAG)*
- [x] **Paso 5 (después):** `pnpm build` y `PORT=3100 DATABASE_URL=…/grafo_tareas_copia?schema=public node dist/main` (puerto
  3100 para no chocar con `bin/dev`); `curl localhost:3100/api/v1/derivado/hoy-puedo` → mismos ids que el Paso 3. Anotar
  ambos totales en este paso. Si difieren, listar los distintos y parar: es un cambio de comportamiento. *(pnpm build OK; API en 3100 contra la copia: ANTES 76 ids, DESPUÉS 76 ids, diff vacío. Con ?espacio=<SIGSA> 76; con un espacio inexistente 0)*
- [x] **Paso 6:** apagar la API del 3100; dejar `grafo_tareas_copia` (Freddy decide si la borra). *(apagada por PID (3100 ya no responde); grafo_tareas_copia queda para que Freddy decida si la borra)*

## Criterios de aceptación

- [x] 1 · Sobre una copia de los datos reales (Tarea 10): los 311 nodos tienen `proyectoId` = SAG y "hoy puedo" devuelve los mismos ids que antes de migrar. *(311/311 en SAG; 76 ids antes, 76 después, diff vacío.)*
- [x] 2 · `POST /espacios {plantilla:'maquinas'}` + `POST /nodos {tipo:'HERRAMIENTA'}` funcionan sin tocar el esquema; un tipo nuevo se crea por API.
- [x] 3 · Un adaptador viejo (sin `proyectoId`) sigue creando nodos, en SAG, con el aviso `X-Aviso-Proyecto`.
- [x] 4 · Los endpoints del método responden igual que hoy para SIGSA y 404 para un espacio sin método.
- [x] 5 · API: lint, type-check, unit y e2e verdes, con cada test nuevo visto en rojo primero (salvo los que se anotan en el informe); web y vr compilan con el cliente regenerado.

## Fuera de alcance

- Web y VR: pestañas de espacio y sub-pestañas de proyecto (variante A del boceto), nodos "fantasma" de otros proyectos → FASE 24.
- Mis máquinas: crear el espacio real y su carga automática desde las fuentes de cada máquina → FASE 25.
- Login, marca de "sensible" y salud (spec §5b).
- Desplegar a producción: lo hace Freddy después de revisar; las migraciones corren en el despliegue.
- Archivar SIGSA: queda visible (Freddy, 2026-11-13).
- Los adaptadores `grafo` (`bin/adapters/grafo/` y la copia del Laboratorio): siguen andando por el proyecto por defecto.
- Editar el nombre de un tipo (renombrar implicaría reescribir los nodos que lo usan).

## Cierre del agente

Al terminar (o al quedar bloqueado), escribir al final de este archivo una sección `## Informe de implementación` con:
tareas hechas y no hechas; totales de tests antes y después (unit, e2e); los dos totales de "hoy puedo" de la Tarea 10;
cada desvío del plan con su motivo; y la lista de archivos tocados en orden de importancia, con qué líneas revisar
(regla global §1). Nada de commits.

## QA

- [ ] Colección — no aplica (proyecto personal, sin Postman)
- [ ] Auditoría
- [ ] Listo para PR
- [ ] Mergeado

## Informe de implementación

**Resultado:** las 10 tareas hechas; los 5 criterios de aceptación cumplidos. Sin commits, sin ramas, sin push. Producción: solo se copió un respaldo (`grafo-2026-11-13_1448.dump`, lectura).

### Totales

| | antes | después |
|---|---|---|
| unit (jest) | 147 en 23 suites | **157 en 26 suites** |
| e2e | 64 en 10 suites | **88 en 11 suites** |
| lint · type-check API | 0 · 0 | 0 · 0 |
| web: lint · tsc · vitest | tsc roto tras regenerar | 0 · 0 · 41/41 (13 archivos) |
| vr: lint · tsc · vitest | tsc roto tras regenerar | 0 · 0 · 175/175 (25 archivos) |

**«Hoy puedo» (Tarea 10), copia del respaldo con 311 nodos:** antes de migrar **76** ids (SQL sobre el esquema viejo; 83 TAREA abiertas); después de migrar y con la API nueva en el puerto 3100, **76** ids; `diff` vacío. Hecho fallar a propósito: sin la excepción de lo mergeado el SQL daría 72; con `?espacio=` de un uuid inexistente la API da 0. La base `grafo_tareas_copia` queda en el Postgres local: la borrás o no, vos.

### Desvíos del plan (cada uno con su motivo)

1. **`tipo` como texto, no `tipoId` (spec §5b línea 94 vs plan):** me preguntaste y elegiste el plan. El spec quedó viejo en esa línea.
2. **La migración `proyecto_obligatorio` se aplicó al final de la Tarea 8 (Paso 3b), no en la 5.** Había ~20 escritores de nodos y ~25 fixtures de e2e que crean nodos sin proyecto; con `NOT NULL` en la Tarea 5 todo habría roto hasta la 7 y la 8. Mismo archivo y nombre que el plan (`20261113000200_…`).
3. **`--proyecto-grafo <uuid>`, no `--proyecto <uuid>`:** los dos CLI ya usaban `--proyecto` (id de Todoist; nombre del orquestador). La lógica vive en `src/importadores/proyecto-grafo.ts`, probable sin `process.exit`.
4. **`EtapasDelEspacioService` nuevo; `EtapasService` queda igual.** Hacer `lista()` asíncrona obligaba a reescribir `roles.service.spec`. `MetodoModule` global aloja `ProyectoPorDefectoService` para que el guard lo vea desde cualquier módulo.
5. **Escritores internos que no nombraba el plan:** los complementos heredan el proyecto de su padre (si no, «hoy puedo» los excluía: lo mostró `complementos.e2e`); piezas usan el proyecto por defecto; adoptar una FASE le pone el proyecto de la corrida.
6. **Asserts tocados (el plan pedía cero):** uno, en `derivado.service.spec` (`bloqueosDe` recibe ahora los tipos bloqueantes como 2.º argumento: firma, no comportamiento). Setup de specs: proveedores nuevos en `nodos.service.spec` y `derivado.service.spec`, fixtures con `proyectoId` en `archivo.spec` y `diferencias.spec`, y `calcular-paginas.spec` envuelve la función con los tipos bloqueantes.
7. **Tipado que el cambio arrastró:** `estado` pasa a `EstadoNodo | null` en `calcular-paginas`, `calcular-tablero-plan`, `NodoResponseDto`, `RamaResponseDto` y `pulido/archivo.ts`. `bin/dev` y `grafo-tareas.api/dist` no se tocaron en caliente (no había `bin/dev` corriendo; `pnpm build` de la API sí reescribió `dist/` de la API).
8. **Web y VR (solo tipos):** web define `TipoNodo`/`TipoConexion` locales (las enums generadas ya no existen) y `TEXTO_CONEXION` pasa a `Record<string, string>`; VR castea en el borde `desde-api.ts` y pasa `undefined` como primer parámetro de `useDerivadoControllerHoyPuedo`. Ninguna UI cambió.
9. **Plan decía 11 e2e:** hay 10 (ahora 11 con `espacios`); 9 vaciaban la base y los 9 usan `vaciarBase` + `sembrarEspacioTrabajo`.
10. **Cumplí el plan en `~/.claude/CLAUDE.md` §18 editando su destino real, `~/dotfiles/claude/CLAUDE.md`** (el primero es un symlink y la herramienta se negó a escribirlo).

### Tests que no vi fallar primero (para que lo sepas)

- Pasaron en su primera corrida porque fijan lo que NO debe cambiar: «una HERRAMIENTA no aparece en hoy puedo», «un BLOQUEADA_POR hacia lo archivado sigue bloqueando», «sin `?espacio=` el método responde como siempre», «restaurar a un proyecto archivado».
- `un tipo nuevo se crea por API…` (criterio 2) lo escribí después del código; su caso rojo está adentro (usar `RECETA` antes de crearla da 400).
- Los 6 casos de `espacios.e2e` de la Tarea 4, `plantillas.spec`, `proyecto-por-defecto.service.spec`, `proyecto-grafo.spec` y los demás nuevos sí se vieron rojos; el mensaje de cada falla está en su paso.

### Incidente (mío) en la VR

`pnpm api:generar` en `grafo-tareas.vr` (que usa npm) instaló por su cuenta: resolvió 745 paquetes, creó `pnpm-lock.yaml` y `pnpm-workspace.yaml` y movió 22 paquetes directos de `node_modules` (más 19 en scopes) a `.ignored_*`. Revertido sin instalar nada: borré los dos archivos nuevos, renombré los 41 de vuelta y borré `.pnpm`, `.modules.yaml` y `.pnpm-workspace-state-v1.json`. Comprobado: `npm ls --depth=0` rc=0 sin missing/invalid/extraneous, los 778 paquetes de `node_modules/.package-lock.json` presentes, `package.json` y `package-lock.json` sin cambios. La trampa quedó en `CLAUDE.md` §Trampas.

### Pendiente de tu lado

- **`bin/importar-en-produccion`** sigue pasando `--proyecto <nombre>` y no `--proyecto-grafo`: con esta FASE falla hasta que le pases el id del proyecto SAG de producción. No lo toqué (script de producción; los adaptadores quedaron fuera de alcance).
- **Despliegue:** las 3 migraciones corren al desplegar; después poner el id del SAG en `PROYECTO_POR_DEFECTO` (o dejarlo vacío: lo busca por nombre). Mismas 311 filas esperables en SAG.
- **Revisión fresca:** no corrí la revisión final con un revisor aparte: tu regla pide que elijas el modelo para un veredicto, y sin commits el paquete de revisión no se arma. El «Review Focus» del plan está cubierto por tests (1–4) y por la Tarea 10 (5).
- No leí `grafo-tareas.api/.env` (denegado); las migraciones corrieron contra `DATABASE_URL` explícita.

### Archivos tocados, en orden de importancia (API salvo que se diga)

1. `prisma/schema.prisma:129` (Espacio, Proyecto, TipoNodo, TipoConexion) y las 3 migraciones de `prisma/migrations/20261113000*`: en `…000100_espacios_datos` revisá las 14 etapas de SIGSA copiadas de `ETAPAS_POR_DEFECTO`.
2. `src/modules/nodos/nodos.service.ts:101` (`create`), `:159` (`conEstadoDelTipo`), `:189` (`tipoDelProyecto`): proyecto por defecto, tipo validado, estado según ciclo, mover con 409.
3. `src/modules/derivado/derivado.repository.ts:46` (`bloqueaAhora`), `:90` (`hoyPuedo`), `:389` (`vecinosDe`) y `derivado.service.ts`: «hoy puedo» y bloqueos desde las tablas, sin lo archivado.
4. `src/modules/metodo/*`, `src/common/guards/requiere-metodo.guard.ts:14`, `src/common/decorators/requiere-metodo.*` y `src/modules/nodos/etapas-del-espacio.service.ts:18`: la capa del método y las etapas por espacio.
5. `src/modules/nodos/proyecto-por-defecto.service.ts:31` + `src/modules/nodos/nodos.controller.ts` (header `X-Aviso-Proyecto`).
6. `src/modules/espacios/` (`plantillas.ts:27`), `src/modules/proyectos/`, `src/modules/tipos/`: los tres módulos nuevos.
7. `src/importadores/aplicar-plan.ts:65`, `src/importadores/fases/importador-fases.service.ts:287,327`, `src/importadores/proyecto-grafo.ts`, los dos `cli.ts`: proyecto explícito.
8. `src/modules/pulido/pulido.repository.ts:59` (restaurar a su proyecto o al de respaldo), `src/modules/complementos/complementos.repository.ts:53` (herencia del proyecto del padre).
9. `src/common/constants/tipos.constants.ts` y los 47 archivos del reemplazo mecánico de la Tarea 3 (diff repetitivo; mirar solo `grafo.constants.ts`, que perdió `CONEXIONES_BLOQUEANTES` y `TIPOS_ACCIONABLES`).
10. `test/espacios.e2e-spec.ts`, `test/fixtures/sembrar-espacio.ts` y los 9 e2e con `vaciarBase` + proyecto en sus fixtures.
11. `openapi.json` (regenerado), `grafo-tareas.web/src/lib/constants/index.ts:4` y `grafo-tareas.vr/src/lib/desde-api.ts:13` (los únicos arreglos a mano de web y VR; el resto es generado).
12. Raíz: `CLAUDE.md` §Trampas (línea 36 y la trampa nueva de npm en la VR), `docs/_CONCEPTO.md`, `docs/backlog/README.md`, `deploy/compose.yml`, y `~/dotfiles/claude/CLAUDE.md` §18 (fuera de este repo).

### Arreglos de la revisión final

Revisión independiente (Opus): «desplegable con arreglos». Cada punto con su e2e visto en rojo primero. Sin commits; migraciones solo locales; nada de producción. `bin/importar-en-produccion` y `PROYECTO_POR_DEFECTO` no se tocaron (son del despliegue).

- [x] **1 · `POST /conexiones` valida el tipo contra la tabla.** `ConexionesService.create` consulta `tipos_conexion` (`ConexionesRepository.existeTipo`) y da 400 con el nombre si no existe. e2e `espacios.e2e-spec.ts`: `tipo:'BLOQUEADO_POR'` → 400, no crea nada, y con `BLOQUEADA_POR` → 201. *(Rojo visto: Expected 400, Received 201.)*
- [x] **2 · El parte del día y las páginas leen solo el espacio que resuelve `MetodoService.espacioDe()`.** `terminadas`, `enColumnas`, `detenidas`, `paraPaginas` filtran por `proyecto: { espacioId }`; también `paraDecir`, `abiertosConEtiqueta` (trámites) y los carriles de `paraTableroPlan`, que tenían el mismo defecto. Las conexiones de las páginas exigen las dos puntas en el espacio. «Sin HU» (`calcular-paginas.ts`) no cambió: ya no recibe nodos ajenos. `dia`, `plan` y `paginas` aceptan `?espacio=` (nuevo en `GET /derivado/paginas`: cambió `openapi.json` y se regeneraron web y VR). e2e `dia.e2e-spec.ts`: una TAREA cerrada, una en curso, una frenada y su bloqueadora en otro espacio no aparecen en `GET /derivado/dia` (sin parámetro ni con `?espacio=<SIGSA>`), y ninguno entra a `GET /derivado/paginas`; los controles de SIGSA («cerrada hoy», «codeando») siguen. *(Rojo visto: «Expected value: not "ajena: cerrada hoy"» y `enPaginas.has(id)` true.)* **Decidido (Freddy): queda así.** Un bloqueo de una tarea de SIGSA hacia algo de otro espacio ya no aparece en la página (sigue contando en `bloqueado`, `libera` y «hoy puedo»); la FASE 24 lo muestra como fantasma.
- [x] **3 · Colgar un complemento exige que el espacio del padre use el método.** `ComplementosService.crear` llama a `MetodoService.exigirDelProyecto(METODO_TRABAJO_HU, padre.proyectoId)` y da el mismo 404 que el guard. e2e `complementos.e2e-spec.ts`: `POST /nodos/<HERRAMIENTA de un espacio sin método>/complementos` → 404 y el conteo de nodos no cambia. *(Rojo visto: Expected 404, Received 201.)* **`escalar` y `decidir` (pedido de Freddy, mismo día):** el chequeo vive en `dudaAbierta`, que comparten: el espacio de la duda tiene que usar el método, si no 404 como el guard, antes de validar nada más. e2e `complementos.e2e-spec.ts`: una DUDA con etiqueta de complemento en un espacio sin método → `escalar` 404 y `decidir` 404; la duda sigue ABIERTA, sin descripción, sin conexiones y sin nodos nuevos. *(Rojo visto: Expected 404, Received 200 en escalar y Received 201 en decidir.)*
- [x] **4 · `PATCH /nodos/:id {estado:null}` en un tipo con ciclo → 400.** `conEstadoDelTipo` (`nodos.service.ts`) lanza `ValidationError` y el estado no cambia. e2e `espacios.e2e-spec.ts`. *(Rojo visto: Expected 400, Received 200.)*

**Totales tras los arreglos:** API lint 0 · type-check 0 · unit **157/157** (26 suites, sin cambio: los arreglos se cubren con e2e) · e2e **95/95** (11 suites; eran 88: +7 casos nuevos, base `_test` migrada). Web: lint 0, tsc 0, vitest 57/57 (14 archivos). VR: lint 0, tsc 0, vitest 175/175 (25 archivos), `npm run api:generar` sin tocar `package*.json`. Setup, no asserts: `derivado.service.spec` suma el proveedor `MetodoService`.

