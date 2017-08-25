module.exports =
  tableName: 'rate'

  schema: true

  attributes:

    from:
      type: 'string'
      reuired: true

    to:
      type: 'string'
      rquired: true

    rate:
      type: 'float'
      required: true
