scheduler = require 'node-schedule'

module.exports =
  bootstrap: ->
    @cron.map ({at, task}) ->
        scheduler.scheduleJob at, ->
          try
            task()
          catch err
            console.error err
    @
