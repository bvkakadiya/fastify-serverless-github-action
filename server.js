import Fastify from 'fastify'
import closeWithGrace from 'close-with-grace'
import appService from './app.js'
import path from 'path'
import AutoLoad from '@fastify/autoload'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Instantiate Fastify with some config
const app = Fastify({
  logger: true,
  pluginTimeout: 10000,
})

// Register your application as a normal plugin.
app.register(appService)

app.register(AutoLoad, {
  dir: path.join(__dirname, 'routes'),
  options: Object.assign({ prefix: 'api' }, opts),
})

// delay is the number of milliseconds for the graceful close to finish
closeWithGrace(
  { delay: process.env.FASTIFY_CLOSE_GRACE_DELAY || 500 },
  async function ({ signal, err, manual }) {
    if (err) {
      app.log.error(err)
    }
    await app.close()
  }
)

// Start listening.
app.listen({ port: process.env.PORT || 3000 }, (err) => {
  if (err) {
    app.log.error(err)
    process.exit(1)
  }
})

export default app
