App = Ember.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  ready: ->
    console.log "ready"

#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./helpers
#= require_tree ./templates
#= require_tree ./routes
