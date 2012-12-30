root = global ? window
root.App = Em.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  currentUser: null
  ready: ->
    console.log "Created App namespace"
    
root.App.deferReadiness()
yam.getLoginStatus (response) ->
  root.App.currentUser = response if response.authResponse and response.authResponse is true
  root.App.advanceReadiness()