App.GroupsController = Em.ArrayController.extend
  setActiveGroup: (selectedGroup = null) ->
    activated = App.Group.allGroups.find (group) => group.get('isActive') is true
    activated.set('isActive', false) if activated?
    selectedGroup.set('isActive', true) if selectedGroup?
    