var fs = require('fs')
var products = fs.readFileSync('./products.json', 'utf8')
const inv = JSON.parse(products)

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
        
        for (var i=0;i<inv.length-1;i++) {
            if (inv[i].id === itemId) {
                return inv[i]
            }
            if (i>inv.length) {
                return "not found"
            }
        }
    })

    fastify.get('/allinventory', options, async (request, reply) => {
        
        return inv
    })    

    next()
}