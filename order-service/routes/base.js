const { DaprClient } = require('dapr-client')
const HttpMethod = require('dapr-client')
const CommunicationProtocolEnum = require('dapr-client')

const daprPort = process.env.DAPR_HTTP_PORT || 9082;
const daprHost = "127.0.0.1"

module.exports = function (fastify, opts, next) {
    
    fastify.get('/', (req, reply) => {
        reply.send({ "orderService": "running", "status": "ok", "version": "0.10" })
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
    
        return ({ "id": orderId, "order": "this is an order" })
    })

    fastify.post('/createorder', options, async (request, reply) => {
        console.log(request.body)

        const client = new DaprClient(daprHost, daprPort, CommunicationProtocolEnum.HTTP)
        const STATE_STORE_NAME = "cosmos-statestore";
    
        await client.state.save(STATE_STORE_NAME,[
            request.body
        ])

        var result = await client.state.get(STATE_STORE_NAME, "order1");
        console.log("Result after get: " + result);

        return ({ "id": "1", "status": "order created" })
    })
  
    next()
}