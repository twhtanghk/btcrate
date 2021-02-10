Koa = require 'koa'
logger = require 'koa-logger'
bodyParser = require 'koa-bodyparser'
methodOverride = require 'koa-methodoverride'
serve = require 'koa-static'
router = require './router'
global.config = require('config')().bootstrap()

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
  .use methodOverride()
  .use router.routes()
  .use serve 'dist'
  .listen parseInt(process.env.PORT) || 3000
  .on 'error', console.error
