App.GroupSidebarController = Em.ObjectController.extend
  updateGroupInfo: (e) ->
    #console.log e
    group = @get('content')
    return null unless group?
    console.log group.get('full_name')