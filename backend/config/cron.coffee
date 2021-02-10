_ = require 'lodash'
moment = require 'moment'
{PublicClient} = require 'coinbase-pro-node-api'
client = new PublicClient()
{indicators} = require 'analysis'

rate = (opts) ->
  _.defaults opts, 
    granularity: 300 # default 300s if not defined
  end = moment()
  start = moment.unix(end.unix() - opts.granularity * 120)
  _.defaults opts,
    end: end.toISOString()
    start: start.toISOString()
  (await client.getHistoricRates opts)
    .map ([time, low, high, open, close, volume]) ->
      date: time
      low: low
      high: high
      open: open
      close: close
      volume: volume

module.exports =
  cron: [
    {
      at: "0 */2 * * * *"
      task: ->
        ret = {}
        for product_id in process.env.PRODUCTS.split ','
          ret[product_id] = {}
          for granularity in [60, 300, 900, 3600, 21600, 86400]
            ret[product_id][granularity] = indicators await rate {product_id, granularity}
        console.log JSON.stringify ret, null, 2
    }
  ]
