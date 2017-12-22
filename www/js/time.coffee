require 'bootstrap/dist/css/bootstrap.css'

_ = require 'lodash'
React = require 'react'
update = require 'react-addons-update'
ReactDataGrid = require 'react-data-grid'
E = require 'react-script'

class Grid extends React.Component
  columns: [
    { key: 'id', name: 'id' }
    { key: 'product', name: 'product' }
    { key: 'date', name: 'date' }
    { key: 'open', name: 'open' }
    { key: 'close', name: 'close' }
    { key: 'low', name: 'low' }
    { key: 'high', name: 'high' }
    { key: 'volume', name: 'volume' }
  ]

  row: (i) =>
    @props.data[i]

  length: =>
    @props.data?.length

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
        update state, data: $push: [action.data]
      else
        state || data: []

