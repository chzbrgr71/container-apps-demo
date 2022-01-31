module.exports = function (fastify, opts, next) {
    
    fastify.get('/', (req, reply) => {
        reply.send({ "inventoryService": "running", "status": "ok", "version": "0.10" })
    })
  
    next()
}