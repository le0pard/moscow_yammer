App.Group = Ember.Object.extend
  isActive: false
  isAllTabActive: (->
    App.Tag.allTags.every (tag) => tag.get('isActive') is false
  ).property('App.Tag.allTags.@each.isActive')
App.Group.reopenClass
  allGroups: []
  prefillGroups: (groups) ->
    activatedId = null
    if @allGroups.length
      activatedObj = @allGroups.find (group) => group.get('isActive') is true
      activatedId = activatedObj.get('id') if activatedObj?
      @allGroups.clear()
    @allGroups.addObjects groups.map((group) ->
      groupObj = App.Group.create group
      groupObj.set('isActive', true) if activatedId? and parseInt(activatedId) is parseInt(groupObj.get('id'))
      groupObj
    )
  find: ->
    @allGroups
  findOne: (id) ->
    @allGroups.find (g) => parseInt(g.get('id')) is parseInt(id)