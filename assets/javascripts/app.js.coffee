root = global ? window
root.App = Ember.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  ApplicationController: Ember.Controller.extend()
  ApplicationView: Ember.View.extend
    templateName: 'application'
  ready: ->
    console.log "Created App namespace"
