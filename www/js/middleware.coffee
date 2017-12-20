io = require 'socket.io-client'
url = require 'url'
path = require 'path'
{toastr} = require 'react-redux-toastr'

opts =
  path: path.join url.parse(window.location.href).pathname, "socket.io"
  reconnection: true
  autoConnect: true

module.exports = (store) -> 
  io '/', opts
    .on 'error', toastr.error
    .on 'disconnect', ->
      toastr.error 'ws disconnected'
    .on 'time', ({verb, id, data}) ->
      store.dispatch 
        type: "time #{verb}"
        data: data
    .on 'delta', ({verb, id, data}) ->
      store.dispatch
        type: "delta #{verb}"
        data: data

  (next) -> (action) ->
    next action
