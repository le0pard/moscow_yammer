App.Group = Ember.Object.extend()
App.Group.reopenClass
  allGroups: []
  prefillGroups: (groups) ->
    @allGroups.clear()
    @allGroups.addObjects groups.map((group) ->
      App.Group.create group
    )
  find: ->
    @allGroups