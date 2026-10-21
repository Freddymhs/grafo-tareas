# DECISIÓN — tres mundos para preparar el día siguiente: Herdr, la daily y la VR

**Fecha:** 2026-10-21 · **Decide:** Freddy («son como tres mundos que todos trabajan en equipo para mejorar un posible
rendimiento durante el próximo día») · **Fuente:** la sesión del grafo del 21-10, con su barra de Herdr y el diseño de
`/flow:daily` acordado ese día en la sesión control.

## Los tres mundos

1. **Herdr, de día.** Freddy ordena a mano: crea el space de cada PBI y FASE y lo arrastra a una de las 3 zonas fijas.
   Las zonas son `▼ EN ESPERA · mergeado`, `control ▼ AHORA` y `atajos ▼ NO ABORDAR`. Las zonas no cambian; el orden lo
   decide él.
2. **`/flow:daily`, en la mañana y sin la VR.** Prepara el conocimiento en modo exprés. Lee Herdr y nunca lo edita.
3. **La VR, de noche, antes de cerrar la jornada.** Sirve para pensar en creativo, ver qué quedó colgando de lo de hoy y
   preparar la daily de mañana.

**Ninguna herramienta reordena Herdr ni decide su orden.** A lo más sugiere movimientos con su motivo.

## Los puentes: datos en el grafo

| de → a | qué | cómo |
|---|---|---|
| mañana → noche | el orden de AHORA | `PUT /api/v1/nodos/orden-del-dia {"ids":[…]}`: las tarjetas `[id]` llevan `hoy:1…n` y las de otro día lo pierden, en una transacción. La VR lo muestra con el lente «hoy» (botón B después del filtro 4). |
| noche → mañana | lo que cambió anoche | `GET /api/v1/cambios`, filtrado por `createdAt` ≥ ayer 18:00 (bitácora con `tipo`, `campo`, `antes`, `despues`, `titulo`). |
| el parte | terminé, en curso, detenido, para decir | `GET /api/v1/derivado/dia` (`?desde=`): no se recalcula en la daily. |

Restricciones de `orden-del-dia`:
- Solo acepta tarjetas TAREA. Una FASE da 400, porque `importar:fases` le reescribe las etiquetas.
- Mover la etiqueta conserva `updatedAt`; si no, una tarjeta cerrada ayer saldría en «terminé» del parte.
- `{"ids":[]}` deja el día vacío.

## Lo que `/flow:daily` necesita además de su diseño (7 puntos, 21-10)

1. **Leer el orden de Herdr, sin proponerlo desde cero.** `herdr workspace list` trae los spaces en el orden de la barra
   (`number`). Las zonas se reconocen por los tokens de los divisores:
   - EN ESPERA: entre `zona_espera` y `zona_ahora`;
   - AHORA: entre `zona_ahora` y `zona_no`;
   - NO ABORDAR: después de `zona_no`.

   El PBI sale del label (`^\d{5,6}`). Es determinista: no hace falta IA. Probado el 21-10, AHORA = 25325, 26610, 26981,
   26973.
2. **«Propuesta del día» = movimientos sugeridos con su motivo**, una línea cada uno, y nunca reordenar. Ejemplo: «26610
   está mergeada y le faltan la evidencia y la wiki: es trámite, ¿sale de AHORA?».
3. **Abrir con lo que cambió desde anoche** (`GET /cambios`): lo que Freddy hizo en la VR.
4. **Cerrar escribiendo AHORA en el grafo** (`PUT /nodos/orden-del-dia`).
   - La tarjeta de cada PBI se busca con `GET /nodos?q=<id>&tipo=TAREA` y es la que empieza con `[<id>]`.
   - Si un PBI de AHORA no tiene tarjeta, se crea con el adaptador `tarjeta` o se avisa.
   - Como Herdr se reordena durante el día, conviene un modo corto que solo resincronice el orden; `sonar` también podría
     llamarlo en cada corrida, porque ya lee Herdr.
5. **Una línea por task de AHORA:** `id · corto · estado del PR · próxima acción · a quién espera`.
   - La próxima acción es la primera casilla sin tildar de Tareas en su FASE.
   - A quién espera sale de `GET /nodos/:id/bloqueado`, sobre la tarjeta y la FASE.
   - Depender de una FASE ya mergeada no cuenta como bloqueo (`dependenciaCumplida`, 21-10).
6. **ESPERA separada en dos:** «espera a otra task o persona» y «mergeada, faltan trámites». Piden acciones distintas.
7. **Forma de la salida:** arriba lo que decide (qué hago primero y qué movería); después las líneas por task; al final,
   el texto de la daily listo para copiar, plano, sin `>` ni viñetas.

## Por qué así

- Cada mundo contesta una pregunta distinta: la cola del día, el «qué sé hoy» y el «por qué / qué quedó colgando».
- Copiar uno en otro duplica y le quita a Freddy el control del orden. Copiar la lista de Herdr en la VR obliga a leer
  en 3D; una daily que reordena Herdr pisa su decisión.
- El grafo es lo único que los tres comparten. Por eso los puentes son datos en el grafo y no texto en un chat.
