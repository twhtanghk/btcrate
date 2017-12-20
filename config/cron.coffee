_ = require 'lodash'
{DataFrame} = require 'dataframe-js'

module.exports =
  cron:
    '0 * * * * *': ->
      sails.log.debug 'analysis job triggered'

      interval = 60000
      df = sails.config.trade.sample.data
      {groupBy, stat} = sails.config.trade.Sample

      curr = Math.floor(Date.now() / interval) * interval
      df = df.filter (row) ->
        curr - interval < row.get('time') <= curr
      _.each groupBy(df, 'side'), (df, side) ->
        _.each groupBy(df, 'product_id'), (df, product) ->
          sails.models.time
            .create _.extend stat(df),
              side: side
              product: product
              tmStart: new Date curr
              tmEnd: new Date(curr - interval)
            .then ->
              sails.models.time.find()
                .where
                  product: product
                  side: side
                .sort tmStart: -1
                .limit 2
            .then (rows) ->
              df = new DataFrame rows
              df = sails.config.df.deltaFieldsY df.sortBy('tmStart'), ['volume', 'size', 'price'], 'tmStart'
              df.map (row) ->
                sails.models.delta
                  .create row.toDict()
                  .toPromise()
            .catch sails.log.error
