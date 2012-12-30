root = global ? window
root.App = Em.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  ready: ->
    console.log "Created App namespace"
    
#root.App.deferReadiness()
#root.App.advanceReadiness()