App.GroupsController = Em.ArrayController.extend
  setActiveGroup: (selectedGroup = null) ->
    activated = App.Group.allGroups.find (group) => group.get('isActive') is true
    activated.set('isActive', false) if activated?
    App.GroupsController.currentSelectedGroup = selectedGroup
    App.GroupsController.currentSelectedGroup.set('isActive', true) if App.GroupsController.currentSelectedGroup?

App.GroupsController.reopenClass
  currentSelectedGroup: null