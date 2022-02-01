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
  
    next()
}