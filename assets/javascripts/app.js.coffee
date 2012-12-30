root = global ? window
root.App = Em.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  currentUser: null
  ready: ->
    console.log "Created App namespace"
    
root.App.deferReadiness()
yam.getLoginStatus (response) ->
  if response.authResponse and response.authResponse is true
    root.App.currentUser = response
    yam.request
      url: "https://www.yammer.com/api/v1/groups.json"
      method: "GET"
      success: (data) ->
        console.log data
        root.App.advanceReadiness()
  else
    root.App.advanceReadiness()