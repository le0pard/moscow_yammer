root = global ? window

root.App.deferReadiness()
yam.getLoginStatus (response) ->
  if response.authResponse and response.authResponse is true
    App.currentUser = response
    App.db = new CouchDB(App.dbName, App.currentUser)
    App.yammerApi.getGroups
      success: (data) ->
        App.db.setGroups data,
          success: (groups) ->
            App.Group.prefillGroups(groups)
            $('#mainContainer').empty()
            root.App.advanceReadiness()
  else
    root.App.advanceReadiness()