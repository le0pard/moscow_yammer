root = global ? window
root.SyncManager =
  isSyncGroup: null
  collectedGroupMessages: []
  mainIterator: 0
  lastMsgId: null
  mainCallback: null
  finishedLoading: ->
    $('#mainContainer').empty()
    root.App.advanceReadiness()
  preloadUsersAndGroups: (callback = {}) ->
    App.db.getGroups
      success: (groups) ->
        unless groups.length
          SyncManager.syncUsersAndGroups
            success: ->
              SyncManager.finishedLoading()
        else
          App.Group.prefillGroups(groups)
          App.db.getUsers
            success: (users) ->
              App.User.prefillUsers(users)
              App.db.getTags
                success: (tags) =>
                  App.Tag.prefillTags(tags)
                  SyncManager.finishedLoading()
  syncUsersAndGroups: (callback = {}) ->
    App.yammerApi.getUsers
      error: ->
        callback.success.call(null) if callback? and callback.success?
      success: (data) ->
        App.db.setUsers data,
          success: (users) ->
            App.User.prefillUsers(users)
            App.yammerApi.getGroups
              error: ->
                callback.success.call(null) if callback? and callback.success?
              success: (data) ->
                App.db.setGroups data,
                  success: (groups) ->
                    App.Group.prefillGroups(groups)
                    callback.success.call(null) if callback? and callback.success?
  fetchMessagesFromGroup: (group, callback = {}) ->
    return false if SyncManager.isSyncGroup isnt null
    SyncManager.isSyncGroup = group
    SyncManager.mainCallback = callback
    yam.request
      url: "/api/v1/messages/in_group/#{SyncManager.isSyncGroup.get('id')}"
      dataType: "json"
      method: "GET"
      data: 
        threaded: true
        limit: 20
      success: (data) ->
        SyncManager.collectedGroupMessages = _.map data.messages, (message) ->
          SyncManager._collectTagInMsg(message)
        SyncManager.mainIterator = 0
        setTimeout(SyncManager.fetchChildMsgForGroup, 3000)
  fetchChildMsgForGroup: (callback = {}) ->
    msg = SyncManager.collectedGroupMessages[SyncManager.mainIterator]
    if msg?
      yam.request
        url: "/api/v1/messages/in_thread/#{msg.id}"
        dataType: "json"
        method: "GET"
        data: 
          limit: 100
        error: ->
          setTimeout(SyncManager.fetchChildMsgForGroup, 5000)
        success: (data) ->
          messages = _.reject data.messages, (message) -> parseInt(msg.id) is parseInt(message.id)
          SyncManager.collectedGroupMessages[SyncManager.mainIterator].messages = _.map messages, (message) ->
            SyncManager._collectTagInMsg(message)
          SyncManager.mainIterator = SyncManager.mainIterator + 1
          setTimeout(SyncManager.fetchChildMsgForGroup, 3000)
    else
      SyncManager.saveGroupMsgData()
  saveGroupMsgData: ->
    ids = _.map SyncManager.collectedGroupMessages, (msg) -> msg.id
    App.db.getMessagesByIds ids,
      success: (messages) ->
        allMessages = _.map SyncManager.collectedGroupMessages, (msg) ->
          oneMsg =
            type: "message"
            content: msg
          tmpMsg = _.find messages, (m) ->
            parseInt(m.doc.content.id) is parseInt(msg.id)
          if tmpMsg?
            oneMsg._id = tmpMsg.doc._id
            oneMsg._rev = tmpMsg.doc._rev
          oneMsg
        App.db.saveMessages allMessages,
          success: (messages) ->
            SyncManager.isSyncGroup = null
            if SyncManager.mainCallback? and SyncManager.mainCallback.success?
              SyncManager.mainCallback.success.call(null)
              SyncManager.mainCallback = null
  _collectTagInMsg: (msg) ->
    msg.tags = msg.body.plain.match(/#(\S+)/gi) if msg.body and msg.body.plain and msg.body.plain.length
    msg
    