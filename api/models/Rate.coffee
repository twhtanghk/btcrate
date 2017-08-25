module.exports =
  tableName: 'rate'

  schema: true

  attributes:

    from:
      type: 'string'
      required: true

    to:
      type: 'string'
      required: true

    rate:
      type: 'float'
      required: true
