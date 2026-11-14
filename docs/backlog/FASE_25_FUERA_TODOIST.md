# FASE 25: LA API SIN IMPORTADORES: NI TODOIST NI `importar:fases`

**Destraba**: que la API deje de nombrar a una herramienta que el trabajo ya no usa (TRABAJO y Draft trabajo se portaron
enteros al grafo), ni el puente de esa mudanza (`importar:fases`). Una FASE llega al grafo como tarjeta, por el adaptador.
**Estado**: hecho en el árbol de trabajo (2026-11-14), sin commit
**Azure**: no aplica (tracker: none)
**Tipo**: devex
**Dependencias**: ninguna
**Fuente**: Freddy, 2026-11-13: «importar toDoist, importar fase en teoría son cosas innecesarias ya. La única fuente
de la verdad son las fases… y el grafo» · aclaración del mismo día: Todoist sigue siendo personal y lo que se dejó es su
uso para el trabajo · Freddy, 2026-11-13, sobre `importar:fases`: «ya no es necesario. Se creó en un comienzo porque
estábamos pasando de Todoist al grafo»

## El hueco, medido

Medido el 2026-11-13:
- **Todoist en la API:**
  - `src/importadores/todoist/` (cliente, traducir, servicio y CLI) y `test/importador.e2e-spec.ts`;
  - el script `importar:todoist` (`package.json:28`);
  - `bin/importar-en-produccion`, en su modo `todoist`;
  - la excepción `grep -v /importadores/` de `.github/workflows/ci.yml:52`.
- **`ImportadoresModule` vive dentro de la carpeta `todoist/`** (`importadores.module.ts`), pero también registra
  `ImportadorFasesService`. `app.module.ts:23` lo importa.
- **`importar:fases` no está suelto: carga dos funciones del grafo que hoy se usan.**
  - La etiqueta `mergeada` de la FASE la pone solo ese importador (`grafo.constants.ts:4`). De ella dependen «lo
    mergeado no bloquea» (FASE 21 D2) y las dos caras de la HU (FASE 17).
  - Los trámites de cierre los deja el mismo importador (`grafo.constants.ts:67`, `dia.dto.ts:86`, FASE 10).
  - `dependenciasViejas` y `--podar` también son suyos (FASE 21 D3).
  - El hook `fase-tilde` mueve la tarjeta a APROBADO sin esperar al importador (`~/.claude/hooks/fase-tilde.sh:16`), pero
    no pone la etiqueta `mergeada` en la FASE.
- **Comparte código con las piezas.** `plan.ts`, `aplicar-plan.ts` y `pieza.ts` cuelgan de `src/importadores/`, y los
  usa `modules/piezas` (`piezas.repository.ts:4-6`, `piezas.service.ts:10-11`).
- **Hoy una FASE nueva llega al grafo de dos maneras:**
  - por `importar:fases`, que trae sus casillas, sus criterios y lo que la bloquea;
  - por el adaptador, `bin/adapters/grafo/etapa "FASE <n>" <etapa> --titulo …`, que crea solo la tarjeta.

## Las decisiones

### D1 · Todoist sale entero de la API — Freddy, 2026-11-13 `[negocio]`

El cliente, el servicio, el CLI, su e2e, el script, el modo `todoist` de `importar-en-produccion` y la excepción del CI.
Si mañana volviera, está en el historial de git.

### D2 · `importar:fases` también sale — Freddy, 2026-11-13 `[negocio]`

Era el puente de la mudanza de Todoist al grafo. Lo que deja de existir, y por qué no hace falta reponerlo:
- **La etiqueta `mergeada`.** «Lo mergeado no bloquea» (FASE 21 D2) ya acepta como mergeada la FASE que está en
  APROBADO, y el hook `fase-tilde` mueve `[FASE <n>]` a APROBADO cuando se tilda `Mergeado`
  (`~/.claude/hooks/fase-tilde.sh:16-18`). La columna basta.
- **Los trámites de cierre.** Eran el cierre en Azure del SAG (URL commit, evidencias, wiki). «El día» sigue mostrando los
  que ya existen y no se crean nuevos.
- **`dependenciasViejas` y `--podar`.** Solo existían para limpiar lo que el importador dejaba.

Una FASE nueva llega al grafo como tarjeta, por `bin/adapters/grafo/etapa "FASE <n>" <etapa> --titulo …` o por el hook
cuando se tilda. Las casillas y los criterios siguen en el `.md`, que es su dueño (FASE 20).

### D3 · Lo que comparten las piezas se muda, no se borra — 2026-11-13 `[código]`

`plan.ts`, `aplicar-plan.ts` y `pieza.ts` dejan `src/importadores/` y pasan a `modules/piezas`. La carpeta
`src/importadores/` desaparece, y con ella `ImportadoresModule` de `app.module.ts:23`.

## Abierto

Ninguno.

## Understand

- [ ] Entendimiento

## Tareas

### `grafo-tareas.api`
- [x] **Tarea 1** · D1 y D2: borrar `src/importadores/todoist/` y `src/importadores/fases/` con sus specs,
  `test/importador.e2e-spec.ts`, `test/importador-fases.e2e-spec.ts`, los scripts `importar:todoist` e `importar:fases`
  y la excepción del CI (`ci.yml:52`), cuyo grep sigue pasando.
- [x] **Tarea 2** · D3: `plan.ts`, `aplicar-plan.ts` y `pieza.ts` (con sus specs) pasan a `modules/piezas`, y se
  arreglan los imports. Los comentarios de `grafo.constants.ts:4` y `:67` y de `dia.dto.ts:86` dejan de nombrar al
  importador. Los unitarios y los e2e quedan en verde; los que salen con la Tarea 1 se cuentan.
- [ ] **Tarea 3** · `README.md` y `openapi.json` sin los importadores; el cliente de web y VR, regenerado si cambió el
  contrato. *(2026-11-14: README y `openapi.json` hechos; el contrato no cambió de rutas ni tipos, solo 4 descripciones:
  falta `api:generar` en web y VR, que solo cambia el comentario de `tramites` en `diaResponseDto.ts`.)*

### `bin`
- [x] **Tarea 4** · se borra `bin/importar-en-produccion`.

### `docs`
- [x] **Tarea 5** · `../CLAUDE.md`, `_CONCEPTO.md`, `roles.yaml` y `diagrams/DIAGRAMAS_COMPONENTES.md` sin los
  importadores como pieza viva. Las FASE que los cuentan (3, 5, 10, 13, 16, 17 y 21) son historia y no se tocan.

## Criterios de Aceptación

- [x] 1 · `grep -rni todoist grafo-tareas.api/src grafo-tareas.api/test` = 0.
- [x] 2 · Una FASE en APROBADO sin la etiqueta `mergeada` no bloquea a quien depende de ella. Hay que confirmar si ese e2e
  ya existe y, si no, se escribe; antes de cerrar este criterio se hace fallar sacando la columna de la regla. *(2026-11-14: no existía para una
  FASE; `test/grafo.e2e-spec.ts` «una FASE en APROBADO sin la etiqueta `mergeada` no bloquea», que falla con la columna
  fuera de `bloqueaAhora`.)*
- [x] 3 · `ls grafo-tareas.api/src/importadores` = no existe; `pnpm build`, unitarios y e2e en verde.
- [ ] 4 · Desplegado: `GET /nodos?tipo=FASE` devuelve lo mismo que antes del despliegue.

## Fuera de alcance

- Todoist personal y sus jobs nocturnos en el Mac Mini.
- Los nodos que el importador de Todoist ya creó: son datos del grafo y se quedan.

## QA

- [ ] Listo para PR
- [ ] Mergeado
- [ ] Adoptado

## Cierre oficial en Azure

- [ ] URL commit
- [ ] Evidencias
- [ ] Wiki actualizada
