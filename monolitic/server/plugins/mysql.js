'use strict'

const fp = require('fastify-plugin')

module.exports = fp(async function (fastify, opts) {
  fastify.register(require('@fastify/mysql'), {
    promise: true,
    connectionString: `mysql://${process.env.MYSQL_USERNAME}:${process.env.MYSQL_PASSWORD}@${process.env.MYSQL_HOSTNAME}/${process.env.MYSQL_DATABASE}`
  })
})
