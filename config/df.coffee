_ = require 'lodash'
{DataFrame, Row} = require 'dataframe-js'
camelCase = require 'camelcase'

module.exports =
  df: 
    delta: (df, fields...) ->
      columns = df.listColumns()
      fields.map (field) ->
        deltaField = camelCase "delta", field
        columns.push deltaField
      ret = new DataFrame [], columns

      last = null
      df.map (row) ->
        if last? 
          reducer = (row, field) ->
            deltaField = camelCase 'delta', field
            row.set deltaField, row.get(field) - last.get(field)
          ret = ret.push fields.reduce reducer, row
        last = row
      ret

    deltaXY: (df, X, Y) ->
      df = @delta df, X, Y
      columns = df.listColumns()
      deltaXY = camelCase 'detla', X, Y
      columns.push deltaXY
      ret = new DataFrame [], columns

      df.map (row) ->
        deltaX = camelCase 'delta', X
        deltaY = camelCase 'delta', Y
        ret = ret.push row.set deltaXY, row.get(deltaX) / row.get(deltaY)
      ret

    deltaFieldsY: (df, fields, Y) ->
      all = [].concat fields, [Y]
      df = @delta.apply @, [df].concat all
      columns = df.listColumns()
      deltaFieldsY = fields.map (field) ->
        camelCase 'delta', field, Y
      ret = new DataFrame [], columns.concat deltaFieldsY

      df.map (row) ->
        reducer = (row, field) ->
          deltaField = camelCase 'delta', field
          deltaY = camelCase 'delta', Y
          deltaFieldY = camelCase 'delta', field, Y
          row = row.set deltaFieldY, row.get(deltaField) / row.get(deltaY)
        row = fields.reduce reducer, row
        ret = ret.push row
      ret
