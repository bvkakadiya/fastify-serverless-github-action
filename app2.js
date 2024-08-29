import fastify from 'fastify'
import AutoLoad from '@fastify/autoload'
import closeWithGrace from 'close-with-grace'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

function init() {
  const app = fastify({ logger: true, pluginTimeout: 10000 })
  app.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
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
  app.get('/', (request, reply) => reply.send({ hello: 'world' }))
  return app
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const app = init()
  // called directly i.e. "node app"
  app.listen({ port: 3000 }, (err) => {
    if (err) console.error(err)
    console.log('server listening on 3000')
  })
}

export default init
