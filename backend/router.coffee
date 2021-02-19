Router = require 'koa-router'
router = new Router()
rate = require './rate'

module.exports = router
  .get '/rate/:id', (ctx, next) ->
    {id} = ctx.params
    ctx.response.body = await rate Object.assign {}, product_id: id, ctx.request.body
