require 'bootstrap/dist/css/bootstrap.css'

_ = require 'lodash'
React = require 'react'
{Map, List} = require 'immutable'
ReactDataGrid = require 'react-data-grid'
E = require 'react-script'

class Grid extends React.Component
  columns: [
    { key: 'date', name: 'date' }
    { key: 'open', name: 'open' }
    { key: 'close', name: 'close' }
    { key: 'low', name: 'low' }
    { key: 'high', name: 'high' }
    { key: 'volume', name: 'volume' }
  ]

  row: (i) =>
    @props.data?.get(@product)?.get(i)

  length: =>
    @props.data?.get(@product)?.size || 0

  constructor: (props) ->
    super props
    @product = props.product || 'BTC-USD'

  render: ->
    E ReactDataGrid,
      columns: @columns
      rowGetter: @row
      rowsCount: @length()
      minHeight: 500

module.exports =
  component: Grid
  reducer: (state, action) ->
    switch action.type
      when 'trade created'
        {data} = state
        {product} = action.data
        if not data.get(product)?
          data = data.set product, List()
        data: data.update product, (list) ->
          list.unshift action.data
      else
        state || data: Map()
