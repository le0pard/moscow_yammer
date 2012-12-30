App.Group = Ember.Object.extend()
App.Group.reopenClass
  allGroups: []
  find: ->
    $.ajax
      url: "https://api.github.com/repos/le0pard/mongodb_logger/contributors"
      dataType: "jsonp"
      context: this
      success: (response) ->
        @allGroups.clear()
        @allGroups.addObjects response.data.map((raw) ->
          App.Group.create raw
        )
    @allGroups