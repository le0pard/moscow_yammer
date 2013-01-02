App.User = Ember.Object.extend()
App.User.reopenClass
  allUsers: []
  prefillUsers: (users) ->
    @allUsers.clear() if @allUsers.length
    @allUsers.addObjects users.map((user) ->
      App.User.create user
    )
  find: ->
    @allUsers
  findOne: (id) ->
    _.find @find(), (u) =>
      parseInt(u.get('id')) is parseInt(id)