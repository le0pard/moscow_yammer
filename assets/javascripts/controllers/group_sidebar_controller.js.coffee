App.GroupSidebarController = Em.ObjectController.extend
  updateGroupInfo: (e) ->
    group = @get('content')
    return null unless group?
    SyncManager.fetchMessagesFromGroup group,
      success: ->
        App.Message.find(App.GroupsController.currentSelectedGroup, App.GroupTagsController.currentSelectedTag)