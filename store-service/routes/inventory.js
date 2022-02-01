const DaprClient = require('dapr-client')
const HttpMethod = require('dapr-client')
const CommunicationProtocolEnum = require('dapr-client')
const got = require('got')

const inventoryUri = 'http://localhost:8081'
const inventoryService = process.env.INVENTORY_SERVICE_NAME || 'inventory-service';
const daprPort = process.env.DAPR_HTTP_PORT || 9081;
const daprSidecar = `http://localhost:${daprPort}`

module.exports = function (fastify, opts, next) {

    const options = {
        schema: {
            querystring: {
                id: { type: 'string' }
            }
        }
      }

    fastify.get('/inventorybyid', options, async (request, reply) => {
        var itemId = request.query.id
        var uri = inventoryUri.concat("/inventorybyid?id=", itemId)

        const res = await got(uri, {
            responseType: 'json'
        })

        return res.body
    })

    fastify.get('/allinventory', options, async (request, reply) => {
        var uri = inventoryUri.concat("/allinventory")

        const res = await got(uri, {
            responseType: 'json'
        })

        return res.body
    })    

    next()

}