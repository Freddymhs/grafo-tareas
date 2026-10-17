# FASE 3: IMPORTADOR TODOIST — UNA DIRECCIÓN, UNA VEZ, IDEMPOTENTE

**Destraba**: ver el trabajo real en el grafo: la FASE 4 (PWA) y la FASE 6 (VR) muestran datos de verdad y no sintéticos
**Listo para PR**: no · FASE escrita el 2026-10-16
**Prioridad**: Alta
**Dependencias**: **FASE 2**. Y antes de importar datos reales: **N1, N2 y C1-C4 confirmados** (`docs/_CONCEPTO.md` § Para confirmar)
**Fuente**: `docs/_CONCEPTO.md` § Lo que Todoist no deja ver, § Fases F1.2, § Cómo se conecta el grafo (Migración), § Riesgos (importador frágil)

> **Alcance:** módulo `importadores/todoist` de `grafo-tareas.api` — **el único lugar del repo que nombra Todoist**. Lee, nunca
> escribe en Todoist. No es sincronización: corre una vez (y de nuevo sin duplicar, por `externo.id`).

## Understand

- [ ] Entendimiento — medir de nuevo, solo lectura, `TRABAJO` completo (134 tareas, se leyeron 100) y `🚀 Draft trabajo`

## Tareas

### Tarea 1: fixtures reales anonimizados
- Exportar por REST (`~/bin/lib/todoist-api.sh`, ya pagina bien) a `test/fixtures/todoist/`. Nombres de personas anonimizados si N1 lo pide.
- [ ] Hecha

### Tarea 2: reglas de traducción, una por test
- Emojis de orden 0️⃣…5️⃣ → `DEPENDE_DE` · círculos 🔵🟢🟠🟣 → `PERTENECE_A` rama · `Depende de: 0.1, 0.2` → conexiones ·
  `esperando a <persona>` → PERSONA + `ESPERA_RESPUESTA_DE` · dudas `W#` → un solo nodo DUDA compartido · `[25327]`/PR/FASE → `externo`.
- [ ] Hecha
- [ ] Cada regla con su caso real del fixture

### Tarea 3: comando de importación
- `pnpm importar:todoist -- --proyecto <id> [--seco]`. `--seco` imprime qué crearía sin escribir. Dos corridas seguidas = 0 nodos nuevos.
- [ ] Hecha

## Criterios de Aceptación

- [ ] 1 · Idempotente: la segunda corrida crea 0 nodos y 0 conexiones
- [ ] 2 · Las 22 tareas con Tomás, 8 con Carabantes y 4 con Fabián quedan colgando de su PERSONA (o de su alias anonimizado)
- [ ] 3 · Ninguna llamada de escritura a Todoist (log de `todoist-api.sh`: solo `GET`)

## QA

- [ ] Colección
- [ ] Auditoría
- [ ] Listo para PR

## Cierre oficial en Azure

- [x] Cierre oficial — no aplica (tracker: none)
