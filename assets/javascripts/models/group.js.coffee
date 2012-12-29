App.Group = DS.Model.extend
  title: DS.attr('string')
  body: DS.attr('string')
  published: DS.attr('boolean')
  find: ->
    console.log "123123"
    []