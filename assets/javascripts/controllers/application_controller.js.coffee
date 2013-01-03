App.ApplicationController = Em.Controller.extend
  updateUsersAndGroups: (e) ->
    button = $(e.currentTarget)
    button.addClass('disabled')
    SyncManager.syncUsersAndGroups
      success: =>
        button.removeClass('disabled')