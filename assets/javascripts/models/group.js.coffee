App.Group = Ember.Object.extend()
App.Group.reopenClass
  allGroups: []
  find: ->
    $.ajax
      url: "https://api.github.com/repos/emberjs/ember.js/contributors"
      dataType: "jsonp"
      context: this
      success: (response) ->
        response.data.forEach ((group) ->
          @allGroups.addObject App.Group.create(group)
        ), this
    @allGroups