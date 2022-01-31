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

        var response = JSON.stringify({
                "id": itemId,
                "itemName": "Thule Roof Rack Base System",
                "quantity": 125
            }
        )

        return response
    })

    next()

}