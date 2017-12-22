require 'bootstrap/dist/css/bootstrap.css'

_ = require 'lodash'
React = require 'react'
update = require 'react-addons-update'
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

  product: 'BTC-USD'

  render: ->
    E ReactDataGrid,
      columns: @columns
      rowGetter: @row
      rowsCount: @length()
      minHeight: 500

{Map, List} = require 'immutable'

module.exports =
  component: Grid
  reducer: (state, action) ->
    switch action.type
      when 'trade created'
        {data} = state
        if not data.get(action.data.product)?
          data = data.set action.data.product, List()
        data: data.set action.data.product, data.get(action.data.product)?.unshift action.data
      else
        state || data: Map()
