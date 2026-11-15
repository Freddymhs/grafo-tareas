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

- **(a) 2026-11-14 · Un commit rojo se despliega con el push verde de otro repo.** `desplegar-aqui.sh` `traer` hace ff a `origin/main` de los 4 repos. Arreglo: avanzar solo `GRAFO_REPO` a `GITHUB_SHA`, el repo cuyo CI pasó.
- ~~**(b) 2026-11-14 · No hay monitor de la VR.**~~ Hecho 2026-11-15: en Kuma no había ninguno del grafo (el `~/uptime-kuma-setup.py` del Mac listaba api y web, pero no estaban cargados). Ahora están API `:3007/api/v1/health`, web `:3008` y VR `:3013`, con aviso al Telegram de Hermes. Ojo: ese script borra todos los monitores antes de crear su lista vieja; no correrlo.
- **(c) 2026-11-14 · D1 dice «la PWA del Quest se reinstala», pero `_CONCEPTO.md:272` dice que Meta no instala PWAs.** Arreglo: cambiar D1 a «URL guardada como favorito» y comprobarlo en el criterio 2.
- **(d) 2026-11-14 · El lint del CI de api es `eslint --fix`, que nunca falla** (`grafo-tareas.api/package.json:16`, `ci.yml:44`). Arreglo: script `lint:ci` sin `--fix` y que el CI lo llame.

## Understand

- [ ] Entendimiento

## Tareas

### `deploy` + `grafo-tareas.vr`
- [x] **Tarea 1** · servicio `vr` en `deploy/compose.yml`, con `Dockerfile` y `.dockerignore` (usuario no root, §9) en la
  VR. El build lo hace Docker en el Mac Mini, con npm y no con pnpm. Suma su puerto a `tailscale serve` y al chequeo
  del despliegue. Hecho el 2026-11-14: `grafo-tareas.vr/Dockerfile` (npm, nginx-unprivileged, uid 101), `deploy/nginx.conf`
  (sin caché para `sw.js`/`index.html`), `127.0.0.1:3013` → `tailscale serve :8448` (`despliegue.vr`), CORS de la API suma la URL.
  Probado en el ThinkPad: 200, `no-cache` en lo que decide el build, la URL de la API adentro.

### CI de cada repo
- [x] **Tarea 2** · registrar el runner de D3 en el Mac Mini, como servicio que arranca solo, igual al de `fmarcos-labs`.
  Hecho el 2026-11-13.
  - En una cuenta personal GitHub registra un runner por repo, así que son tres: `mac-mini-grafo-{api,web,vr}`, con
    etiquetas `mac-mini` y `grafo`, en `~/actions-runner-grafo-<repo>` y como LaunchAgent. Los tres quedaron online.
  - Los binarios son una copia real de la 2.338.2 del runner de `fmarcos-labs`. Una copia con rsync conservaba los
    symlinks `bin/` y `externals/` hacia `~/actions-runner`, y `config.sh` lo tomaba por ya configurado.
  - De paso se vio que el runner de `fmarcos-labs` está caído desde el 2026-11-13 a las 10:06, antes de esta tarea:
    `Get next message failed with non-retryable error` en `~/Library/Logs/actions.runner.fmarcos-labs.mac-mini/stdout.log`.
- [x] **Tarea 3** · job `deploy` en el `ci.yml` de `api`, `web` y `vr` (D2). La lógica de despliegue sale de
  `bin/desplegar` a un script que corre en el Mac Mini, sin duplicarla. `bin/desplegar` pasa a llamar a ese mismo script.
  Hecho el 2026-11-14: `deploy/desplegar-aqui.sh` (candado `mkdir`, lee `despliegue` de `refs.yaml`, verifica 5 contenedores
  y CORS de web y VR). El job lo corre desde `origin/main` del orquestador. Un 4.º runner, `mac-mini-grafo-raiz`, para el
  workflow `Despliegue` de la raíz. Los 4 runners y el de `fmarcos-labs` llevan `KeepAlive`: el de `fmarcos-labs` estuvo
  caído desde el 13-11 porque, tras un corte de red, el LaunchAgent solo tenía `RunAtLoad` (probado: se mata y vuelve en <75 s).
  Antes el CI de los tres repos estaba en rojo: ubuntu-latest pasó a 26.04 sin Playwright (se fija 24.04), los e2e de web
  y vr no simulaban `/espacios` tras la FASE 26, y la API nombraba `todoist` (FASE 25).
  Trampa del primer despliegue automático (run 43614272807): `credsStore: desktop` se cuelga desde el LaunchAgent
  (`load metadata` 35 min, «error getting credentials»), así que el script usa su propio `DOCKER_CONFIG` sin ayudante. Y el
  candado de 15 min fijos lo rompieron web y vr: ahora guarda el pid de su dueño y solo se libera si ese pid murió.

### Docs
- [x] **Tarea 4** · `deploy/README` o `CLAUDE.md`: el flujo es «push a main». `bin/desplegar` queda como el camino a mano
  para una emergencia. Hecho el 2026-11-14 en `CLAUDE.md` §Comandos.

## Criterios de Aceptación

- [x] 1 · Un commit de prueba pusheado a `main` de la web queda en producción sin correr nada a mano, y su job `deploy`
  aparece en verde en GitHub.
  Hecho el 2026-11-14: web `98af349`, api `7ff09fa`, vr `9e8e674` y la raíz `8afa34f`, los cuatro con tests y `deploy` en verde.
  El de la raíz verificó 5 contenedores, health/PWA/VR 200 y CORS de web y VR.
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
