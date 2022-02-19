const { DaprClient } = require('dapr-client')
const HttpMethod = require('dapr-client')
const CommunicationProtocolEnum = require('dapr-client')
const daprHost = "localhost"
//const daprPort = process.env.ORDER_DAPR_HTTP_PORT || 9083
//const daprGrpcPort = process.env.ORDER_DAPR_GRPC_PORT || 7083
const inventoryService = process.env.INVENTORY_SERVICE_NAME || 'inventory-service'
const orderService = process.env.ORDER_SERVICE_NAME || 'order-service'

const options = {
    schema: {
        querystring: {
            id: { type: 'string' }
        }
    }
  }

module.exports = function (fastify, opts, next) {
    
    fastify.get('/', (req, reply) => {
        reply.send({ "storeService": "running", "status": "ok", "version": "0.10" })
    })

    fastify.get('/orderbyid', options, async (request, reply) => {
        var orderId = request.query.id
        
        const client = new DaprClient(daprHost, process.env.DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP)
        const result = await client.invoker.invoke(orderService , "orderbyid?id=" + orderId, HttpMethod.GET)
        return result
    })  

    fastify.post('/neworder', options, async (request, reply) => {
        // sample order request: {"orderid":"100199","itemid":"7","description":"Santa Cruz Hightower 29er MTB","location":"Denver","priority":"Standard"}

        //const client = new DaprClient(daprHost, daprGrpcPort, CommunicationProtocolEnum.GRPC)
        const client = new DaprClient(daprHost, process.env.DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP)
        const result = await client.invoker.invoke(orderService, "createorder", HttpMethod.POST, request.body)
        return result
        // return request.body
    })   

    fastify.get('/inventorybyid', options, async (request, reply) => {
        var itemId = request.query.id
        
        const client = new DaprClient(daprHost, process.env.DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP)
        const result = await client.invoker.invoke(inventoryService , "inventorybyid?id=" + itemId, HttpMethod.GET)
        return result
    })

    fastify.get('/allinventory', options, async (request, reply) => {

        const client = new DaprClient(daprHost, process.env.DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP)
        const result = await client.invoker.invoke(inventoryService , "allinventory", HttpMethod.GET)
        return result
    
    })  

    fastify.get('/inventorystatus', options, async (request, reply) => {

        //const client = new DaprClient(daprHost, daprPort, CommunicationProtocolEnum.HTTP)
        const client = new DaprClient(daprHost, process.env.DAPR_HTTP_PORT, CommunicationProtocolEnum.HTTP)
        const result = await client.invoker.invoke(inventoryService , "/", HttpMethod.GET)
        return result
    
    })     
  
    next()
}