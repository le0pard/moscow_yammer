root = global ? window

root.App.deferReadiness()
yam.getLoginStatus (response) ->
  if response.authResponse and response.authResponse is true
    App.currentUser = response
    App.db = new CouchDB(App.dbName, App.currentUser)
    SyncManager.preloadUsersAndGroups()
  else
    SyncManager.finishedLoading()