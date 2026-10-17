// recargar-visor.mjs <puerto-cdp> <origen> <build-esperado> — que el visor muestre el build NUEVO de la VR.
// El navegador del Quest guarda la VR en su service worker y, tras un build, puede seguir mostrando la anterior
// (real 2026-10-17: el grafo sintético de la FASE 1 en vez del real, y otra vez sin las etiquetas nuevas). Por la
// depuración remota (CDP, `adb forward … localabstract:chrome_devtools_remote`) borra el service worker y la caché
// SOLO de <origen>, recarga sus pestañas y comprueba que corran <build-esperado> (el `index-*.js` de dist/).
const [puerto = '9333', origen = 'http://localhost:4173', esperado = ''] = process.argv.slice(2)
const ESPERA_CARGA_MS = 6000

const abrir = (url) =>
  new Promise((resolver, fallar) => {
    const ws = new WebSocket(url)
    ws.addEventListener('open', () => resolver(ws))
    ws.addEventListener('error', () => fallar(new Error(`no abre ${url}`)))
  })

const llamar = (ws, id, method, params = {}) =>
  new Promise((resolver, fallar) => {
    const alRecibir = ({ data }) => {
      const mensaje = JSON.parse(data)
      if (mensaje.id !== id) return
      ws.removeEventListener('message', alRecibir)
      if (mensaje.error) fallar(new Error(`${method}: ${mensaje.error.message}`))
      else resolver(mensaje.result)
    }
    ws.addEventListener('message', alRecibir)
    ws.send(JSON.stringify({ id, method, params }))
  })

const pestanasDeLaVr = async () =>
  (await (await fetch(`http://localhost:${puerto}/json`)).json()).filter(
    ({ type, url }) => type === 'page' && url.startsWith(origen),
  )

const SCRIPTS = "[...document.scripts].map((s) => s.src.split('/').pop()).join(',')"

const antes = await pestanasDeLaVr()
if (antes.length === 0) {
  console.log(`visor: no hay pestañas de ${origen} abiertas (--abrir la abre)`)
  process.exit(0)
}
for (const [i, { webSocketDebuggerUrl }] of antes.entries()) {
  const ws = await abrir(webSocketDebuggerUrl)
  if (i === 0) {
    await llamar(ws, 1, 'Storage.clearDataForOrigin', {
      origin: origen,
      storageTypes: 'service_workers,cache_storage',
    })
  }
  await llamar(ws, 2, 'Page.reload', { ignoreCache: true })
  ws.close()
}
await new Promise((r) => setTimeout(r, ESPERA_CARGA_MS))

const resultados = await Promise.all(
  (await pestanasDeLaVr()).map(async ({ webSocketDebuggerUrl }) => {
    const ws = await abrir(webSocketDebuggerUrl)
    const { result } = await llamar(ws, 1, 'Runtime.evaluate', { expression: SCRIPTS, returnByValue: true })
    ws.close()
    return String(result.value)
  }),
)
const viejas = resultados.filter((scripts) => esperado !== '' && !scripts.split(',').includes(esperado))
console.log(
  viejas.length === 0
    ? `visor: ✓ ${resultados.length} pestaña(s) con el build nuevo${esperado ? ` (${esperado})` : ''}`
    : `visor: ✗ ${viejas.length} de ${resultados.length} pestaña(s) siguen con otro build: ${viejas.join(' | ')}`,
)
process.exit(viejas.length === 0 ? 0 : 1)
