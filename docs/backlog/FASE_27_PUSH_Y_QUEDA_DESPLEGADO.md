# FASE 27: PUSH A MAIN Y QUEDA DESPLEGADO: API, WEB Y VR, SIN COMANDOS

**Destraba**: que Freddy solo commitee y pushee. El CI prueba y despliega, y el visor abre la VR desde el Mac Mini sin que
el ThinkPad esté encendido ni haya que correr nada.
**Estado**: sin rama
**Azure**: no aplica (tracker: none)
**Tipo**: devex
**Dependencias**: FASE 12 (el despliegue en el Mac Mini)
**Fuente**: Freddy, 2026-11-13: «se supone que el deploy es automático cuando yo comiteo… hay un CICD para el API, para
el frontend… nada de complicar a la persona con comandos extra… no es realista que yo vaya a hacer esos comandos»

## El hueco, medido

Medido el 2026-11-13:
- **El CI solo prueba, no despliega.** `.github/workflows/ci.yml` corre en `push` a `main` en los tres repos y no tiene
  ningún paso de despliegue.
- **Desplegar es un comando a mano** desde el ThinkPad: `bin/desplegar`, por ssh (`bin/desplegar:2-8`).
- **Por qué no es automático:** el runner de GitHub del Mac Mini solo toma repos de `fmarcos-labs`, y los de grafo-tareas
  son de `Freddymhs` (`bin/desplegar:10`).
- **La VR no está desplegada.** `deploy/compose.yml` tiene `postgres`, `api`, `web` y `respaldo`, sin `vr`. El Quest
  abre `localhost:4173`, que solo existe mientras el ThinkPad corre `bin/probar-en-visor`. Si nadie lo corre, el Quest
  muestra el build viejo que tiene guardado.

## Las decisiones

### D1 · La VR se despliega igual que la web — 2026-11-13 `[código]`

- Es un servicio más en `deploy/compose.yml`: build estático, servido en `127.0.0.1` y publicado con `tailscale serve`
  en su propio puerto HTTPS. WebXR exige contexto seguro, y el certificado del tailnet lo da.
- La PWA del Quest se reinstala desde esa URL una vez.
- `bin/probar-en-visor` queda solo para medir FPS con el ThinkPad, no para usar la VR.

### D2 · El despliegue lo hace el CI, después de que los tests pasan — 2026-11-13 `[código]`

- Un job `deploy` en el `ci.yml` de cada repo, con `needs:` del job de tests, solo en `push` a `main`.
- Hace lo mismo que `bin/desplegar` hoy, idempotente, para el servicio de ese repo.

### D3 · Un runner más en el Mac Mini, para los repos de `Freddymhs` — 2026-11-13 `[código]`

Freddy no tenía preferencia. Se elige el runner y no la mudanza porque no cambia remotos ni clones. El runner abre él la
conexión hacia GitHub, así que no se expone nada a internet.

## Abierto

Ninguno.

## Understand

- [ ] Entendimiento

## Tareas

### `deploy` + `grafo-tareas.vr`
- [ ] **Tarea 1** · servicio `vr` en `deploy/compose.yml`, con `Dockerfile` y `.dockerignore` (usuario no root, §9) en la
  VR. El build lo hace Docker en el Mac Mini, con npm y no con pnpm. Suma su puerto a `tailscale serve` y al chequeo
  del despliegue.

### CI de cada repo
- [x] **Tarea 2** · registrar el runner de D3 en el Mac Mini, como servicio que arranca solo, igual al de `fmarcos-labs`.
  Hecho el 2026-11-13.
  - En una cuenta personal GitHub registra un runner por repo, así que son tres: `mac-mini-grafo-{api,web,vr}`, con
    etiquetas `mac-mini` y `grafo`, en `~/actions-runner-grafo-<repo>` y como LaunchAgent. Los tres quedaron online.
  - Los binarios son una copia real de la 2.338.2 del runner de `fmarcos-labs`. Una copia con rsync conservaba los
    symlinks `bin/` y `externals/` hacia `~/actions-runner`, y `config.sh` lo tomaba por ya configurado.
  - De paso se vio que el runner de `fmarcos-labs` está caído desde el 2026-11-13 a las 10:06, antes de esta tarea:
    `Get next message failed with non-retryable error` en `~/Library/Logs/actions.runner.fmarcos-labs.mac-mini/stdout.log`.
- [ ] **Tarea 3** · job `deploy` en el `ci.yml` de `api`, `web` y `vr` (D2). La lógica de despliegue sale de
  `bin/desplegar` a un script que corre en el Mac Mini, sin duplicarla. `bin/desplegar` pasa a llamar a ese mismo script.

### Docs
- [ ] **Tarea 4** · `deploy/README` o `CLAUDE.md`: el flujo es «push a main». `bin/desplegar` queda como el camino a mano
  para una emergencia.

## Criterios de Aceptación

- [ ] 1 · Un commit de prueba pusheado a `main` de la web queda en producción sin correr nada a mano, y su job `deploy`
  aparece en verde en GitHub.
- [ ] 2 · Con el ThinkPad apagado, el Quest abre la VR desde la URL del Mac Mini y muestra las pestañas.
- [ ] 3 · Un push con un test rojo no despliega: se prueba a propósito una vez.

## Fuera de alcance

- Desplegar los `~/bin` o los dotfiles: no son servicios.

## QA

- [ ] Listo para PR
- [ ] Mergeado
- [ ] Adoptado

## Cierre oficial en Azure

- [ ] URL commit — no aplica
- [ ] Evidencias
- [ ] Wiki actualizada — no aplica
