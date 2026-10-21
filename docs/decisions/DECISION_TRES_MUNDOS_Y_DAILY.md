# DECISIÓN — cómo se combinan la web del grafo, la VR, la daily y Herdr

**Fecha:** 2026-10-21 · **Decide:** Freddy («no es exclusivo de que de un lado se manda la información al otro… es una
combinación de todos») · **Fuente:** la sesión del grafo del 21-10, con su barra de Herdr y el diseño de `/flow:daily`
acordado ese día en la sesión control.

## Cada herramienta, su momento

1. **La web del grafo, durante el día laboral.** Ahí se trabaja: tareas, búsquedas y lo nuevo que se crea.
2. **La VR, de noche o el fin de semana, cansado y lejos del computador.** Es un repaso rápido: qué hice hoy, qué quedó
   pendiente, en qué quedé. Conecta la memoria del día con la de largo plazo, despierta lo creativo y ordena la cabeza.
3. **`/flow:daily`, temprano.** Mira la base del grafo y da un veredicto por task: esta avanza, esta espera (a quién),
   esta es trámite, esta para después. Lo agrupa como las zonas de Herdr, y es lo que Freddy le presenta al líder.
4. **Herdr, después.** Freddy ordena la barra con todo eso: toma una task y la abre con `/flow:paralelo`, o baja la
   infraestructura de una bloqueada, como la vio en la VR. Después de la daily puede pedirle a la IA que le ordene la barra
   según lo acordado con el líder. Herdr no reordena por CLI, así que la IA entrega los arrastres exactos.

No hay un flujo de un solo sentido. Freddy decide, creativamente, con lo que le muestran todos.

**Herdr nunca escribe en el grafo** (Freddy, 21-10: «yo puedo hacer cualquier tontería en mi Herdr… vamos a romper cosas
de la base de datos»). Herdr es un borrador de trabajo y el grafo es la base. La daily lee el grafo para su veredicto y la
barra solo para compararla; no copia nada de un lado al otro.

## Lo que la daily lee del grafo

| qué | cómo |
|---|---|
| lo que cambió anoche (lo hecho en la VR) | `GET /api/v1/cambios`, filtrado por `createdAt` ≥ ayer 18:00 (bitácora con `tipo`, `campo`, `antes`, `despues`, `titulo`). |
| el parte: terminé, en curso, detenido, para decir | `GET /api/v1/derivado/dia` (`?desde=`): no se recalcula en la daily. |
| a quién espera cada task | `GET /api/v1/nodos/:id/bloqueado` sobre la tarjeta y la FASE. |

El 21-10 se probó guardar el orden de AHORA en el grafo (`PUT /nodos/orden-del-dia` y un lente «hoy» en la VR), copiado
de Herdr. Se sacó el mismo día (revert `1cd8226` y del lente en la VR): Herdr no mueve el grafo «ni para un lado ni para
el otro».

## `/flow:daily`

Los pasos viven en el comando: `~/.claude/commands/flow/daily.md`. Lo que no cambia:
- **El veredicto sale del grafo**, no de la barra: esta avanza (próxima acción de su FASE), esta espera (`GET
  /nodos/:id/bloqueado`; depender de una FASE ya mergeada no cuenta), esta es trámite, esta para después.
- **Se agrupa como las zonas de Herdr** (AHORA · EN ESPERA · NO ABORDAR) y termina con el texto para la daily.
- **La barra se lee para compararla** (`~/bin/zonas-herdr`, solo lee) y nunca se mueve. Ordenarla es después de la daily
  y a pedido de Freddy.
- **No escribe nada**: lo que encuentra mal en el grafo lo dice en el parte.

## Por qué así

- Cada herramienta contesta otra pregunta: la web, «qué hago ahora»; la VR, «qué quedó y en qué quedé»; la daily, «con qué
  avanzo hoy y qué me frena»; Herdr, «en qué orden lo abro».
- Copiar uno en otro duplica y le quita a Freddy el control del orden. Copiar la lista de Herdr en la VR obliga a leer
  en 3D; una daily que reordena Herdr pisa su decisión.
- El grafo es la base que los tres comparten; Herdr no. Por eso el grafo se lee desde todos lados y solo se escribe con
  intención (la web, la VR, los comandos que anotan), nunca como copia de la barra.
