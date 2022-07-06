var fs = require('fs')
var products = fs.readFileSync('./products2.json', 'utf8')
const inv = JSON.parse(products)

module.exports = function (fastify, opts, next) {
    
    fastify.get('/', (req, reply) => {
        reply.send({ "inventoryService": "running", "status": "ok", "version": "2.00" })
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

    fastify.get('/inventorybyid', options, async (request, reply) => {
        var itemId = request.query.id
        
        for (var i = 0; i < inv.length; i++) {
            if (inv[i].id == itemId) {
                return inv[i]
            }
            if (i == inv.length-1) {
                return ({ "id": itemId, "result": "Item not found" })
            }
        }
    })

    fastify.get('/allinventory', options, async (request, reply) => {
        
        return inv
    })    

    next()
}