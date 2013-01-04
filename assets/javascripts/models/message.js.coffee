App.Message = Ember.Object.extend()
App.Message.reopenClass
  allMessages: []
  find: ->
    @allMessages