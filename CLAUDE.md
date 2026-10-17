@~/.claude/metodo.md

# CLAUDE.md — grafo-tareas (personal)

## Stack

## Trampas de este proyecto

- **Nest inyecta hasta los parámetros con valor por defecto.** `constructor(config, http: Fetch = fetch)` → Nest intenta resolver `http`, falla, y con `logger: false` **aborta en silencio** (exit 1, cero salida). Los tests no lo ven: el e2e reemplaza la clase entera y el unit la construye a mano. Dependencias que no son providers van por token (`@Inject(FETCH)`) y los CLI llevan `abortOnError: false` + `catch` que imprime. *(Real 2026-10-16, `todoist.client.ts`.)*
- **Los CLI de la API corren desde `dist`, nunca con ts-node:** los alias `@config/x.js` (con sufijo `.js`) ts-node no los resuelve; `tsc-alias` sí, en el build. Patrón: `"script": "pnpm build && node dist/<cli>"` (`openapi:export`, `importar:todoist`).
- **Los e2e comparten `grafo_tareas_test`:** jest en paralelo los pisa (conteos de más, personas duplicadas). `test/jest-e2e.json` lleva `maxWorkers: 1`; cada suite limpia la base en `beforeAll`.
- **lint-staged pasa Prettier por los `.json` staged:** un archivo generado (`openapi.json`) que se commitea crudo queda distinto del que genera el script y el CI falla por `git diff --exit-code`. Todo script que genera un archivo versionado termina en `prettier --write` sobre él.
- **Sin `let` tampoco en los specs** (regla global §0): nada de `let service; beforeEach(...)`. Unit: `const armar = async () => …compile()` y `const service = await armar()` por test. e2e: `const ctx = {} as {…}` que llena `beforeAll` una sola vez.
- **Lo derivado se calcula sobre TAREAS:** `hoy-puedo` con FASE/RAMA adentro daba 96 de 80 abiertas con datos reales. `TIPOS_ACCIONABLES` es la única lista; se mide contra la base local importada antes de creer un número.

## Reglas de este proyecto
