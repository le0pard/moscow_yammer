App.GroupController = Em.ObjectController.extend
  updateGroupInfo: (e) ->
    console.log e
    group = @get('content')
    console.log group
    console.log group.get('full_name')