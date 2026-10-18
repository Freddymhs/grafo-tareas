// entrar-vr.mjs <url> — lleva la pestaña de la VR del Quest a <url> y toca «Entrar en VR» por CDP (el toque cuenta como gesto del usuario).
// Antes: adb -s <serial> forward tcp:9333 localabstract:chrome_devtools_remote · y siempre vía ~/bin/quest-despierto.
const [URL_VR] = process.argv.slice(2)
const PUERTO = 9333
const pestanas = await (await fetch(`http://localhost:${PUERTO}/json`)).json()
const pestana = pestanas.find((p) => p.type === 'page' && p.url.startsWith('http://localhost:4173'))
if (!pestana) { console.log('sin pestaña de la VR en el Quest'); process.exit(1) }
const ws = new WebSocket(pestana.webSocketDebuggerUrl)
await new Promise((r) => ws.addEventListener('open', r, { once: true }))
const pendientes = new Map()
ws.addEventListener('message', (e) => { const m = JSON.parse(e.data); pendientes.get(m.id)?.(m); pendientes.delete(m.id) })
const enviar = (() => { const contador = { n: 0 }; return (method, params = {}) => new Promise((r) => { contador.n += 1; pendientes.set(contador.n, r); ws.send(JSON.stringify({ id: contador.n, method, params })) }) })()
const esperar = (ms) => new Promise((r) => setTimeout(r, ms))
await enviar('Page.navigate', { url: URL_VR })
await esperar(9000)
const rect = await enviar('Runtime.evaluate', { returnByValue: true, expression: `(() => { const b = [...document.querySelectorAll('button')].find((x) => x.textContent.includes('Entrar en VR')); if (!b) return null; const r = b.getBoundingClientRect(); return { x: r.x + r.width / 2, y: r.y + r.height / 2, build: [...document.scripts].map((s) => s.src).find((s) => s.includes('index-')) } })()` })
const pos = rect.result?.result?.value
if (!pos) { console.log('sin botón «Entrar en VR»'); process.exit(1) }
for (const type of ['mousePressed', 'mouseReleased']) await enviar('Input.dispatchMouseEvent', { type, x: pos.x, y: pos.y, button: 'left', clickCount: 1 })
await esperar(3000)
const enVr = await enviar('Runtime.evaluate', { returnByValue: true, expression: `!!navigator.xr && document.body.innerText.slice(0, 80)` })
console.log(JSON.stringify({ build: pos.build?.split('/').pop(), tocado: true, texto: enVr.result?.result?.value }))
ws.close()
