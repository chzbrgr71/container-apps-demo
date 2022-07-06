const { DaprClient } = require('dapr-client')
const HttpMethod = require('dapr-client')
const CommunicationProtocolEnum = require('dapr-client')

const daprPort = process.env.DAPR_HTTP_PORT || 9082;
const daprHost = "127.0.0.1"
const STATE_STORE_NAME = "cosmos-statestore"

module.exports = function (fastify, opts, next) {

    fastify.get('/', (req, reply) => {
        reply.send({ "orderService": "running", "status": "ok", "version": "0.10" })
    })

    fastify.get('/healthz', (req, reply) => {
        // use this code for normal operation (instead of below)
        reply.send({ "status": "ok" })

        // use this code to simulate an error for the health check
        //reply.statusCode = 500
        //reply.send({ "status": "fail" })
    })    

    const options = {
        schema: {
            querystring: {
                id: { type: 'string' }
            }
        }
    }

    fastify.get('/orderbyid', options, async (request, reply) => {
        var orderId = request.query.id

        const client = new DaprClient(daprHost, daprPort, CommunicationProtocolEnum.HTTP)

        var result = await client.state.get(STATE_STORE_NAME, orderId);
        console.log("Order result: " + result);

        return result
    })

    fastify.post('/createorder', options, async (request, reply) => {
        // sample order request: {"orderid":"100199","itemid":"7","description":"Santa Cruz Hightower 29er MTB","location":"Denver","priority":"Standard"}
        var orderPayload = request.body
        var outdata = {
            "key": orderPayload.orderid,
            "value": orderPayload
        }

        const client = new DaprClient(daprHost, daprPort, CommunicationProtocolEnum.HTTP)
        await client.state.save(STATE_STORE_NAME, [
            outdata
        ])
        console.log("order created: " + orderPayload.orderid)
        return ({ "status": "order created", "payload": outdata })
    })

    next()
}