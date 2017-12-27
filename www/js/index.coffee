require 'react-redux-toastr/src/styles/index.scss'

React = require 'react'
E = require 'react-script'
ReactDOM = require 'react-dom'
MuiThemeProvider = require('material-ui/styles/MuiThemeProvider').default
{compose, createStore, combineReducers, applyMiddleware} = require 'redux'
{Provider, connect} = require 'react-redux'
Toastr = require 'react-redux-toastr'
Time = require './time.coffee'

reducer = combineReducers
  toastr: Toastr.reducer
  time: Time.reducer

composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore reducer, {}, composeEnhancers applyMiddleware require './middleware.coffee'

Time.component = connect(((state) -> state.time))(Time.component)

elem =
  E Provider, store: store,
    E MuiThemeProvider,
      E 'div',
        E Toastr.default
        E Time.component, product: 'ETH-BTC'
        E Time.component, product: 'BTC-USD'

ReactDOM.render elem, document.getElementById 'root'
