{compile} = require 'coffeescript'
analysis = require 'analysis'
rate = require '../rate'

module.exports =
  cron: [
    {
      at: "0 */5 * * * *"
      task: ->
        ret = {}
        for product_id in process.env.PRODUCTS.split ','
          ret[product_id] = {}
          for granularity in [60, 300, 900, 3600, 21600, 86400]
            indicators = analysis
              .indicators await rate {product_id, granularity}
            if eval compile process.env.CONDITION
              console.log { product_id, granularity, indicators }
    }
  ]
