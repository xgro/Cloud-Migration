'use strict'

module.exports = async function (fastify, opts) {
  fastify.get('/', async (request, reply) => {
      let data;
      const params = {
        TableName: "product"
      };

      try {
        data = await fastify.dynamo.scan(params).promise();
        return { data }
      } catch (e) {
        reply.send(e)
      }
    }
  )

  fastify.get('/:id', async (request, reply) => {
      let data;
      const { id } = request.params;

      const params = {
        TableName: "product",
        Key: {
          id: parseInt(id)
        }
      };

      try {
        data = await fastify.dynamo.get(params).promise();
        return { data }
      } catch (e) {
        reply.send(e)
      }
    }
  )

  fastify.post('/', async function (request, reply) {
    const {id, name, price, description} = request.body

    const newItem = {
      TableName: "product",
      Item: {
        id,
        name,
        price,
        description
      }
    }

    try {
      await fastify.dynamo.put(newItem).promise();
      reply.code(201).send(newItem)
    } catch (e) {
      reply.send(e)
    }

  })
}
