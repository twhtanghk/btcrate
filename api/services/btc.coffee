_ = require 'lodash'
Promise = require 'bluebird'
{ getAsync } = Promise.promisifyAll require 'needle'

module.exports =
  currency: (list = ['HKD', 'USD', 'EUR']) ->
    ret = {}
    rates = Promise.promisifyAll require 'bitcoin-exchange-rates'
    Promise
      .map list, (currency) ->
        rates
          .fromBTCAsync 1, currency
          .then (rate) ->
            ret[currency] = rate
      .then ->
        ret

  btc_eth: ->
    getAsync 'https://shapeshift.io/rate/btc_eth'
      .then (res) ->
        ETH: res.body.rate

  rate: ->
    Promise
      .all [@currency(), @btc_eth()]
      .then (res) ->
        _.extend res[0], res[1]
      .then (rates) ->
        ret = {}
        _.map rates, (rate, currency) ->
          ret[currency] = parseFloat rate
        ret
