{compile} = require 'coffeescript'
analysis = require 'analysis'
rate = require '../rate'
client = require 'mqtt'
  .connect process.env.MQTTURL,
    username: process.env.MQTTUSER
    clientId: process.env.MQTTCLIENT
    clean: false
  .on 'error', console.error

module.exports =
  cron: [
    {
      at: "0 */5 * * * *"
      task: ->
        ret = {}
        for product_id in process.env.PRODUCTS.split ','
          ret[product_id] = {}
          for granularity in [60, 300, 900, 3600, 21600, 86400]
            indicators = analysis.indicators await rate {product_id, granularity}
            if eval compile process.env.CONDITION, bare: true
              msg = JSON.stringify {product_id, granularity, indicators}
              client.publish 'stock/alert', msg
    }
  ]
