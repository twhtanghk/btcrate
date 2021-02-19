_ = require 'lodash'
moment = require 'moment'
{PublicClient} = require 'coinbase-pro-node-api'
client = new PublicClient()

###
opts:
  product_id: (default BTC-USD)
  granularity: (optional with default 300s)
  start: start time in ISO string format (optional with default 120 historical data)
  end: start time in ISO string format (optional with default now))
###
module.exports = (opts) ->
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
