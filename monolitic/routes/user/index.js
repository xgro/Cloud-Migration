'use strict'

module.exports = async function (fastify, opts) {
  fastify.post('/login', async function (request, reply) {
    const {loginname, password} = request.body
    const connection = await fastify.mysql.getConnection()

    const [rows, fields] = await connection.query(
      `SELECT * FROM users WHERE loginname = '${loginname}' and password='${password}'`, []
    )
    connection.release()

    const user = rows[0]
    console.log(user)
    if(rows.length > 0) {
      const {name, role} = rows[0]
      const token = fastify.jwt.sign({"id":user.id, "loginname": loginname, "name": name, "role": role})
      reply.send({ token })
    } else {
      reply.code(401).send({ 'message': "유효한 로그인네임과 패스워드가 아닙니다." })
    }
  })

  fastify.decorate("authenticate", async function(request, reply){
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.code(401).send(err)
    }
  })

  fastify.get("/", {
    onRequest:[fastify.authenticate]
  },
  async function(request, reply) {
    console.log("request.user", request.user)

    return request.user
  })

  fastify.post("/signup", async function (request, reply){
    const {loginname, password, name} = request.body

    const connection = await fastify.mysql.getConnection()
    const [rows, fields] = await connection.query(
      `insert into users (loginname, password, name, role) values (?, ?, ?, ?)`, [loginname, password, name, 'member']
    )
    connection.release()

    // TODO: 중복 회원가입에 대한 에러처리 필요
    reply.code(201).send({'message': 'ok'})
  })

}
