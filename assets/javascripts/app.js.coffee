root = global ? window
root.App = Em.Application.create
  VERSION: '1.0'
  rootElement: '#mainContainer'
  dbName: "moscow_yammer"
  currentUser: null
  db: null
  yammerApi: new YammerApi
  ready: ->
    console.log "Created App namespace"