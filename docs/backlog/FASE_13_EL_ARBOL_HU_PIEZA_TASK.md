# FASE 13: EL ÁRBOL — HU → PIEZA → TASK (TARJETA Y FASE), COMO TRABAJA FREDDY

**Destraba**: que la VR muestre el trabajo real como red y no como nube: cada HU un racimo, sus piezas por crear y tomadas, y qué
espera a quién. Hoy 48 de 85 tareas abiertas están sueltas (medido 2026-10-17 en producción)
**Listo para PR**: sí · Freddy confirmó el modelo el 2026-10-17 («sí, constrúyelo»); api `d778d50`, vr `cb656bf`, orquestador `526b8ca` + `80831b8`. Falta solo que Freddy lo mire en el visor (`bin/probar-en-visor --api --abrir`)
**Prioridad**: Alta — es lo que Freddy quiere ver («donde voy a apreciar el resultado es en la VR»)
**Dependencias**: FASE 3 (importador Todoist), FASE 5 tarea 3 (importador de FASE), FASE 12 (se importa contra producción)
**Fuente**: `docs/_CONCEPTO.md` § Cómo trabaja Freddy · Azure leído el 2026-10-17 (solo lectura, `bin/adapters/azure` del Laboratorio) ·
`/flow:pbi:repartir` · `Laboratorio/docs/referencia/equipo-y-proceso.md` § Vocabulario

> **Alcance:** solo los importadores (leen; nunca escriben en Todoist ni en Azure) y la VR si hace falta mostrar el racimo.
> **No se infiere nada que los formatos no digan**: cada regla lee un texto que un comando de Freddy escribe siempre igual.

## Lo medido — de dónde sale cada regla

- **Azure (2026-10-17):** HU = PBI, un solo nivel (`Product Backlog Item`, verificado en el Laboratorio el 2026-09-13); debajo, **Tasks**.
  Freddy tiene 44 tasks: 27 de la 19565, 10 de la 20379, 4 de la 22204 (onboarding). **Creó él 23 de las 44** (24881, 25016, 25476,
  25699, las 12 de Sonar…); Persona B 5, Persona F 14, Persona G 1. 19 sin cerrar (11 en revisión, 8 en espera).
- **FASE ↔ Task:** 34 de las 35 `FASE_*.md` del Laboratorio traen `**Azure**: task <id> (padre HU <n>)`.
- **TRABAJO:** 82 de 134 tarjetas citan un id de Azure; las 34 de las FASE aparecen todas. Sin FASE: 20379 (la HU), 24549, 24551, 24914
  (tasks de otros), 25682 (Sonar) y 26469 (una task de Persona B que creó Freddy).
- **Draft:** 7 piezas, todas de la HU 20379; título `<ronda> 20379 · <N.M> · <título> · <task|por crear>`, sección = carril
  (`A · Bandeja`, `B · Acceso y KPIs`, `C · Recepción`); el encaje (rondas, qué mergea primero) en la descripción del proyecto.
- **Una pieza que se toma es la misma tarjeta** (`/flow:pbi:repartir` §5: «al tomarla, esa misma tarjeta pasa al tablero»): en Todoist
  conserva su id al cambiar de proyecto → en el grafo es un solo nodo por `externo`.

## Las reglas (para confirmar con Freddy, C12)

- **R1 · HU:** un nodo HISTORIA por PBI (`externo` `tracker`/`hu:<id>`), titulado con su nombre del tracker. **Cambió al construir:** el mapa task → HU no sale de la prosa de la FASE (solo 21 de 35 la nombran, con cinco redacciones, y las 15-21 de la 20379 no la dicen) sino del tracker: `bin/importar-en-produccion` lo lee de Azure con el adaptador del orquestador (solo GET) y lo pasa como `--padres <json>`; la API no nombra Azure. Lo citan las FASE (`padre HU <n>`),
  las piezas (`HU <n>`) y las tarjetas que nombran la HU.
- **R2 · FASE → su HU:** cada FASE `PERTENECE_A` la HU de su cabecera.
- **R3 · Tarjeta → su FASE:** una tarjeta que cita el id de Azure de una FASE `PERTENECE_A` esa FASE (no se fusionan: la tarjeta es la
  proyección del tablero y la FASE el documento; D10 las marca a las dos a propósito).
- **R4 · El Draft:** se importa con el mismo importador (proyecto `6P4h8Wp2pW59Fq2x`, solo lectura). Cada pieza = TAREA etiqueta
  `pieza` y `ronda:<n>`, `PERTENECE_A` su HU y una RAMA por carril (`20379 · C · Recepción`). «por crear» / «descartada» quedan en la
  etiqueta; sin «depende de» inventado (la tarjeta no lo trae; el mapa de `repartir` vive en su carpeta).

## Understand

- [x] Entendimiento — 2026-10-17: Freddy explicó su flujo; Azure y los formatos medidos (arriba); modelo confirmado por Freddy

## Tareas

### Tarea 1: R1 + R2 en el importador de FASE
- [x] Hecha — 2026-10-17: `traducir-fases.ts` (`Padres`, `nodoHistoria`), `--padres` en el CLI, validación del JSON; `NodoPlan.origen`/`soloSiFalta` para la HU compartida; unit 3 casos

### Tarea 2: R3 — la tarjeta cuelga de su FASE
- [x] Hecha — 2026-10-17, en el importador de FASE (es el que sabe qué task tiene cada FASE): `engancharTarjetas`, id como número entero (e2e: `249721` no engancha `24972`)

### Tarea 3: R4 — el Draft
- [x] Hecha — 2026-10-17: `traducir.ts` reconoce la pieza por la cabecera de `repartir` (no por el título, que cambia al tomarla); carriles `A · zona` → RAMA con color; unit 5 casos sobre 3 tarjetas reales

### Tarea 4: medir y mirar
- [x] 2026-10-17 en producción: **tareas abiertas sueltas 48 → 35** (de 92: + las 7 piezas); HU 19565 con 25 conexiones, HU 20379 con 16; **64 tarjetas** colgando de su FASE; 15 «FASE n» fusionadas, 0 duplicadas. VR: `?reordenar` (las posiciones guardadas no se movían con las conexiones nuevas, C2) + HU dorada con nombre fijo, FASE lila, aristas del árbol visibles; captura: el racimo de la 19565 alrededor de su HU. **Las 35 que quedan** son notas (retros, propuestas, «para Persona B») que ninguna regla de este modelo toca: si se quieren conectar, otra FASE con su regla aprobada

## Criterios de Aceptación

- [x] 1 · Cada regla con su test sobre fixtures reales — API unit 79 · e2e 42 · VR 33
- [x] 2 · `--seco` primero en los tres pasos; sueltas 48 → 35, las que quedan son notas sin regla
- [ ] 3 · La VR muestra las HU como racimos — **captura ✅ (19565)**; **Freddy lo confirma en el visor**

## QA

- [x] Colección — no aplica: no agrega rutas
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
