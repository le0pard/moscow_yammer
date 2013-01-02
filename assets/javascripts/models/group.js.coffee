App.Group = Ember.Object.extend
  isActive: false
App.Group.reopenClass
  allGroups: []
  prefillGroups: (groups) ->
    @allGroups.clear() if @allGroups.length
    @allGroups.addObjects groups.map((group) ->
      App.Group.create group
    )
  find: ->
    @allGroups
  findOne: (id) ->
    _.find @find(), (g) =>
      parseInt(g.get('id')) is parseInt(id)