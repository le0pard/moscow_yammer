root = global ? window
root.App = Em.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  currentUser: null
  ready: ->
    console.log "Created App namespace"
    
#root.App.deferReadiness()
#root.App.advanceReadiness()