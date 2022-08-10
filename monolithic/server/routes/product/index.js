'use strict'

const products = [
  {id: 1, name: '2021년 달력', price: 6000, description: '최-신 2021년 달력'},
  {id: 2, name: '외계어 번역기', price: 12000, description: '화성어과 금성어간의 통역이 가능합니다'},
]

module.exports = async function (fastify, opts) {
  fastify.decorate("authenticate", async function(request, reply){
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.code(401).send(err)
    }
  })

  fastify.get('/', {
    onRequest:[fastify.authenticate]
  }, async function (request, reply) {
    reply.send(products)
  })

  fastify.post('/', {
    onRequest:[fastify.authenticate]
  }, async function (request, reply) {
    const {name, price, description} = request.body
    const newItem = {
      id: products.length,
      name,
      price,
      description
    }
    products.push(newItem)
    reply.code(201).send(newItem)
  })
}
