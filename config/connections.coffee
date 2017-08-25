[
  'DB'
].map (name) ->
  assert name of process.env, "process.env.#{name} not yet defined"

module.exports =
  connections:
    mongo:
      adapter: 'sails-mongo'
      driver: 'mongodb'
      url: process.env.DB
