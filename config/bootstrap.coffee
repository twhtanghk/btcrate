_ = require 'lodash'
schedule = require 'node-schedule'

module.exports =
  bootstrap: (cb) ->
    sails.config.crontab.jobs = _.map sails.config.crontab, (task, at) ->
      schedule.scheduleJob at, task
    cb()
