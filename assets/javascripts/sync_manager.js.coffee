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
    SyncManager.isSyncGroup.setProperties({'isLoadingData': true, 'progressGroupStyle': 'width: 0'})
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
          allTags = []
          last_message = _.clone(SyncManager.collectedGroupMessages[SyncManager.mainIterator])
          allTags = allTags.concat(SyncManager.collectedGroupMessages[SyncManager.mainIterator].tags) if SyncManager.collectedGroupMessages[SyncManager.mainIterator].tags?
          messages = _.reject data.messages, (message) -> parseInt(msg.id) is parseInt(message.id)
          SyncManager.collectedGroupMessages[SyncManager.mainIterator].messages = _.map messages, (message) ->
            tmpMsg = SyncManager._collectTagInMsg(message)
            allTags = allTags.concat(tmpMsg.tags) if tmpMsg.tags?
            tmpMsg
          if SyncManager.collectedGroupMessages[SyncManager.mainIterator].messages? and SyncManager.collectedGroupMessages[SyncManager.mainIterator].messages.length
            last_message = _.clone(SyncManager.collectedGroupMessages[SyncManager.mainIterator].messages[0])
          SyncManager.collectedGroupMessages[SyncManager.mainIterator].last_message = last_message
          SyncManager.collectedGroupMessages[SyncManager.mainIterator].all_tags = _.uniq(allTags)
          SyncManager.mainIterator = SyncManager.mainIterator + 1
          setTimeout(SyncManager.fetchChildMsgForGroup, 3000)
          # PERCENT
          percent = Math.ceil((SyncManager.mainIterator / SyncManager.collectedGroupMessages.length) * 100)
          percent = 100 if percent > 100
          SyncManager.isSyncGroup.set('progressGroupStyle', "width: #{percent}%")
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
            SyncManager.isSyncGroup.setProperties({'isLoadingData': false})
            SyncManager.isSyncGroup = null
            if SyncManager.mainCallback? and SyncManager.mainCallback.success?
              SyncManager.mainCallback.success.call(null)
              SyncManager.mainCallback = null
  _collectTagInMsg: (msg) ->
    msg.tags = msg.body.plain.match(/#(\S+)/gi) if msg.body and msg.body.plain and msg.body.plain.length
    msg.tags = (tag.toLowerCase() for tag in msg.tags) if msg.tags? and msg.tags.length
    msg
    