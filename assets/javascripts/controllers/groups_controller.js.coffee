App.GroupsController = Em.ArrayController.extend
  setActiveGroup: (selectedGroup = null) ->
    activated = App.Group.allGroups.filter (group) =>
      group.get('isActive') is true
    activated.map (group) =>
      group.set('isActive', false)
    selectedGroup.set('isActive', true) if selectedGroup?
    