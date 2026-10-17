# FASE 9: COMPLEMENTOS — LO QUE CUELGA DE UN PBI

**Destraba**: que dudas, decisiones y «para decir» vivan pegadas a su PBI y una duda sepa a quién se escala después — C11, sobre la base de la FASE 8
**Listo para PR**: no · FASE escrita el 2026-10-17 (borrador, sin humano: nada de código hasta cerrar las decisiones de abajo)
**Prioridad**: Alta
**Dependencias**: FASE 8 (roles)
**Fuente**: `docs/_CONCEPTO.md` § Para confirmar C11 (complementos, escalera, PBI borrador)

> **Alcance:** un complemento no es un rol: es un nodo chico conectado a un PBI (HISTORIA) o a una task. Los 12 tipos de C11:
> duda de negocio · duda de código · dolor · supuesto · decisión · para decir · propuesta · trámite · apunte · evidencia ·
> trabajo de otro · captura rápida. PBI sin número = HISTORIA borrador.

## Understand

- [ ] Entendimiento — pendiente. Medido para arrancar (2026-10-17): `TipoNodo` tiene TAREA, HISTORIA, FASE, RAMA, DUDA, PERSONA, PR, DAILY_ITEM; `TipoConexion` DEPENDE_DE, ESPERA_RESPUESTA_DE, BLOQUEADA_POR, PERTENECE_A, EN_DAILY_DE. Las dos dudas y «para decir» ya tienen tipo (DUDA, DAILY_ITEM + EN_DAILY_DE); los otros 9 no.

**Decisiones para Freddy antes de codear (afirmaciones; contestar «1 ok, 2 no»):**
1. **Sin migración:** un complemento es un nodo DUDA (las dos dudas) o TAREA (el resto) con la etiqueta `complemento:<tipo>`, conectado `PERTENECE_A` a su HISTORIA/TAREA — mismo patrón que el rol en la FASE 8 (etiqueta, filtro en la API). Alternativa: un valor nuevo en `TipoNodo` por tipo (9 valores, migración de Prisma). Propongo la etiqueta: los tipos son del método y cambian; el enum es esquema.
2. **Los 12 tipos viven en `roles.yaml` del área** (bloque `complementos:` con clave, nombre, tipo de nodo), no en la API: misma SSOT que los roles, la PWA los lee por `GET /roles` (o `GET /complementos`).
3. **La escalera vive en `refs.yaml` del área:** `escalera: { negocio: [codigo, carabantes, tomas-soto|nicolas], codigo: [tomas-soto, carabantes] }` con las personas como nodos PERSONA. Escalar = la DUDA pasa de `ESPERA_RESPUESTA_DE` la persona actual a la siguiente; la anterior queda en la descripción (quién, cuándo).
4. **Decisión = la duda contestada:** cerrar una DUDA pide «quién contestó y dónde quedó» y deja un nodo `complemento:decision` que la reemplaza en el PBI. No se borra la duda.
5. **Para decir** cuelga de un ritual (`daily`, `retro`, `1:1 Fabián`) como DAILY_ITEM `EN_DAILY_DE` el nodo del ritual; el «parte para Fabián» (idea a pedido) sale de ahí.
6. **PBI borrador:** HISTORIA sin `externo` (sin número de Azure); cuando tiene número, se le pone el externo y queda conectada a su origen (rol Negocio → Producto).

## Tareas

### Tarea 1: el catálogo — `complementos:` en `roles.yaml` y lectura en la API
- [ ] Hecha

### Tarea 2: escalera de dudas — `refs.yaml` del área + escalar desde la PWA
- [ ] Hecha

### Tarea 3: la PWA — complementos en el detalle del PBI (crear, escalar, cerrar como decisión)
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · Desde un PBI se crea una duda de negocio, se escala dos veces y se cierra como decisión, y queda todo el rastro
- [ ] 2 · Agregar un tipo de complemento es una línea en `roles.yaml`, sin tocar código

## QA

- [x] Colección — no aplica: proyecto personal, sin Postman
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
