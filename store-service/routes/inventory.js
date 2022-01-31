const got = require('got')
const uri = 'http://localhost:8081/inventory/check?id=999'

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

    fastify.get('/check', options, async (request, reply) => {
        var itemId = request.query.id

        const res = await got(uri, {
            responseType: 'json'
        })

        //return response
        return res.body
    })

    next()

}