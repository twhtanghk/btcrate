require 'bootstrap/dist/css/bootstrap.css'

_ = require 'lodash'
React = require 'react'
update = require 'react-addons-update'
ReactDataGrid = require 'react-data-grid'
E = require 'react-script'

class Grid extends React.Component
  columns: [
    { key: 'id', name: 'id', locked: true }
    { key: 'product', name: 'product', sortable: true }
    { key: 'side', name: 'side', sortable: true }
    { key: 'volume', name: 'volume', sortable: true }
    { key: 'size', name: 'size', sortable: true }
    { key: 'price', name: 'price', sortable: true }
    { key: 'min', name: 'min', sortable: true }
    { key: 'max', name: 'max', sortable: true }
    { key: 'tmStart', name: 'start time', sortable: true }
    { key: 'tmEnd', name: 'end time', sortable: true }
  ]

  row: (i) =>
    @props.data[i]

  length: =>
    @props.data.length

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
      when 'time created'
        update state, data: $push: [action.data]
      else
        state || data: []
