const got = require('got')
const orderUri = 'http://localhost:8081'

// const inventoryService = process.env.INVENTORY_SERVICE_NAME || 'inventory-service';
// const daprPort = process.env.DAPR_HTTP_PORT || 3500;
// const daprSidecar = `http://localhost:${daprPort}`

module.exports = function (fastify, opts, next) {

    const options = {
        schema: {
            querystring: {
                id: { type: 'string' }
            }
        }
      }

    fastify.get('/orderbyid', options, async (request, reply) => {
        var itemId = request.query.id
        var uri = inventoryUri.concat("/inventorybyid?id=", itemId)

        const res = await got(uri, {
            responseType: 'json'
        })

        return res.body
    })  

    next()

}