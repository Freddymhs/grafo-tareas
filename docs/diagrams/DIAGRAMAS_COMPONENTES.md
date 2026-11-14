# Diagramas de Componentes (Flowcharts)

Propósito: mapa estable del sistema. Actualizar solo si cambia topología. Fuente: `../_CONCEPTO.md` § Stack y § Cómo se conecta el grafo.

## Contexto (alto nivel)

```mermaid
flowchart LR
  F[Freddy] -->|Quest Browser, WebXR| VR[grafo-tareas.vr]
  F -->|teléfono / PC| WEB[grafo-tareas.web PWA]
  F -->|/flow:* · hooks| MET[método: contrato del tablero]
  VR -->|REST · hooks Orval| API[grafo-tareas.api]
  WEB -->|REST · hooks Orval| API
  MET -->|bin/adapters/grafo · F2| API
  API -->|Prisma| DB[(Postgres · Neon)]
```

## Componentes principales

```mermaid
flowchart TB
  subgraph Tailscale["Tailnet (sin login en v0)"]
    subgraph MacMini["Mac Mini · Docker"]
      API[NestJS · Fastify<br/>nodos · conexiones · ramas · derivado · piezas]
      WEBS[Next.js PWA]
      VRS[Vite build VR]
    end
    Q[Quest 3S] --> VRS
    T[Teléfono / PC] --> WEBS
  end
  API --> NEON[(Neon Postgres)]
  API -->|OpenAPI exportado| ORV[Orval → tipos + TanStack Query]
  ORV --> WEBS
  ORV --> VRS
```
