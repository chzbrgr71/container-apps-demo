const app = require('fastify')({ logger: true })
const port = 8083

// plug-ins
app.register(require('fastify-healthcheck'))
app.register(require('fastify-swagger'), {
  routePrefix: '/swagger',
  exposeRoute: true
})
app.register(require('./routes/base'))

// start server
app.listen(port,'0.0.0.0', function (err, address) {
    if (err) {
        app.log.error(err)
      process.exit(1)
    }
    // Server is now listening
})