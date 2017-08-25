module.exports =
  crontab:
    "0 */3 * * * * *": ->
      sails.services.btc
        .rate()
        .then (rates) ->
          _.map rates, (rate, currency) ->
            sails.models.rate.create
              from: 'btc'
              to: currency
              rate: rate
        .catch sails.log.error
