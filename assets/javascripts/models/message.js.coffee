App.Message = Ember.Object.extend()
App.Message.reopenClass
  allMessages: []
  prefillMessages: (messages) ->
    @allMessages.clear() if @allMessages.length
    @allMessages.addObjects messages.map((message) ->
      App.Message.create message
    )
  find: (group, tag = null) ->
    @allMessages