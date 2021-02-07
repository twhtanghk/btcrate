Router = require 'koa-router'
router = new Router()

module.exports = router
  .get '/rate/:from/:to', (ctx, next) ->
    {from, to} = ctx.params

