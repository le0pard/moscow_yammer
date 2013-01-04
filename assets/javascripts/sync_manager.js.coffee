root = global ? window
root.SyncManager =
  finishedLoading: ->
    $('#mainContainer').empty()
    root.App.advanceReadiness()
  preloadUsersAndGroups: (callback = {}) ->
    App.db.getGroups
      success: (groups) ->
        unless groups.length
          SyncManager.syncUsersAndGroups
            success: ->
              SyncManager.finishedLoading()
        else
          App.Group.prefillGroups(groups)
          App.db.getUsers
            success: (users) ->
              App.User.prefillUsers(users)
              App.db.getTags
                success: (tags) =>
                  App.Tag.prefillTags(tags)
                  SyncManager.finishedLoading()
  syncUsersAndGroups: (callback = {}) ->
    App.yammerApi.getUsers
      error: ->
        callback.success.call(null) if callback? and callback.success?
      success: (data) ->
        App.db.setUsers data,
          success: (users) ->
            App.User.prefillUsers(users)
            App.yammerApi.getGroups
              error: ->
                callback.success.call(null) if callback? and callback.success?
              success: (data) ->
                App.db.setGroups data,
                  success: (groups) ->
                    App.Group.prefillGroups(groups)
                    callback.success.call(null) if callback? and callback.success?