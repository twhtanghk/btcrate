Koa = require 'koa'
logger = require 'koa-logger'
bodyParser = require 'koa-bodyparser'
serve = require 'koa-static'
router = require './router'

app = new Koa()
app
  .use (ctx, next) ->
    try
      await next()
    catch err
      ctx.status = err.status || 500
      ctx.body = err.message
      ctx.app.emit 'error', err
  .use logger()
  .use require 'koa-404-handler'
  .use bodyParser()
  .use methodOverrider()
  .use router.routes()
  .use serve 'dist'
  .listen parseInt(processenv.PORT) || 3000
  .on 'error', console.error
