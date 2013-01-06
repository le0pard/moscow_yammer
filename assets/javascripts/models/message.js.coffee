App.Message = Ember.Object.extend()
App.Message.reopenClass
  allMessages: []
  _findSender: (msg) ->
    App.User.allUsers.find (user) ->
      parseInt(user.id) is parseInt(msg.sender_id)
  prefillMessages: (messages) ->
    @allMessages.clear() if @allMessages.length
    @allMessages.addObjects messages.map((message) =>
      message.sender = @_findSender(message)
      message.messages = (_.extend(replMsg, {sender: @_findSender(message)}) for replMsg in message.messages) if message.messages? and message.messages.length
      App.Message.create message
    )
  find: (group, tag = null) ->
    @allMessages.clear() if @allMessages.length
    App.db.getMessagesByGroupAndTag group, tag,
      success: (messages) =>
        @prefillMessages(messages)
    @allMessages