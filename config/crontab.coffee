_ = require 'lodash'
Promise = require 'bluebird'

module.exports =
  crontab:
    "0 */3 * * * * *": ->
      sails.services.btc
        .rate()
        .then (rates) ->
          Promise.all _.map rates, (rate, currency) ->
            sails.models.rate.create
              from: 'BTC'
              to: currency
              rate: rate
        .catch sails.log.error
