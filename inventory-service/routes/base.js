module.exports = function (fastify, opts, next) {
    
    fastify.get('/', (req, reply) => {
        reply.send({ "inventoryService": "running", "status": "ok", "version": "0.10" })
    })

    const options = {
        schema: {
            querystring: {
                id: { type: 'string' }
            }
        }
      }

    fastify.get('/inventorybyid', options, async (request, reply) => {
        var itemId = request.query.id

        var response = JSON.stringify({
                "id": itemId,
                "itemName": "Thule Roof Rack Base System",
                "quantity": 125
            }
        )

        return response
    })

    fastify.get('/allinventory', options, async (request, reply) => {
    
        var response = JSON.stringify([
                {
                    "id": 1,
                    "itemName": "Thule Roof Rack Base System",
                    "quantity": 125
                },
                {
                    "id": 2,
                    "itemName": "Ski Carrier",
                    "quantity": 39
                }
            ]
            
        )

        return response
    })    

  
    next()
}