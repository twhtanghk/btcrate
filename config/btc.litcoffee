    _ = require 'lodash'
    Promise = require 'bluebird'
    btc = require 'bitcoinjs-lib'
    needle = Promise.promisifyAll require 'needle'
    
    module.exports =
    
return key pair for specified private wif or create key pair if not specified

      keyPair: (privateWIF = null) ->
        keyPair = if privateWIF? then btc.ECPair.fromWIF privateWIF else btc.ECPair.makeRandom()
        address: keyPair.getAddress()
        wif: keyPair.toWIF()
    
return balance for the specified public address

      balance: (address) ->
        needle
          .getAsync "https://blockchain.info/balance?active=#{address}"
          .then (res) ->
            res.body
    
      tx:

list all txs for the specified public address

        list: (address) ->
          needle
            .getAsync "https://blockchain.info/rawaddr/#{address}"
            .then (res) ->
              res.body

return last tx for the specified public address

        last: (address) ->
          module.exports.tx
            .list()
            .then (res) ->
              last = res.txs.pop()
              tx = _.find last.out, addr: address
              hash: last.hash
              index: tx.n
                
create tx to send value of satochi from 'fromWIF' to specified public address 'to'
publish tx hex via https://blockchain.info/pushtx

        create: (fromWIF, to, value) ->
          from = btc.ECPair.fromWIF fromWIF
          txb = new btc.TransactionBuilder()
          module.exports.tx
            .last()
            .then (last) ->
              txb.addInput last.hash, last.index
              txb.addOutput to, value
              txb.sign 0, from
              txb.build().toHex()
