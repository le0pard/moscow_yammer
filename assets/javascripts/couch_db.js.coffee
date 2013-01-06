root = global ? window
class root.CouchDB
  constructor: (@databaseName, @user) ->
    @db = $.couch.db(@databaseName)
    @db.compact
      success: (data) =>
        # done
  _sortGroups: (groups) =>
    groups.sort (a, b) =>
      return -1 if (a.full_name < b.full_name)
      return 1 if (a.full_name > b.full_name)
      return 0
  _sortTags: (tags) =>
    _.sortBy tags, (tag) -> parseInt(tag.sort_index)
  getGroups: (callback = {}) =>
    @db.view "#{@databaseName}/groups",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (allGroups) =>
        groups = (group.value for group in allGroups.rows)
        callback.success.call(null, @_sortGroups(groups)) if callback? and callback.success?
  setGroups: (groups, callback = {}) =>
    @db.view "#{@databaseName}/groups",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (data) =>
        allGroups = []
        for group in groups
          oneGroup =
            type: "group"
            content: group
          if data.total_rows
            oldGroup = _.find data.rows, (g) ->
              g.doc.content.id is group.id
            if oldGroup
              oneGroup._id = oldGroup.doc._id
              oneGroup._rev = oldGroup.doc._rev
          allGroups.push oneGroup
        @db.bulkSave {docs: allGroups},
          success: (data) =>
            groups = (group.content for group in allGroups)
            callback.success.call(null, @_sortGroups(groups)) if callback? and callback.success?
  getUsers: (callback = {}) =>
    @db.view "#{@databaseName}/users",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (usersData) =>
        users = (user.value for user in usersData.rows)
        users = users.sort (a, b) =>
          return -1 if (a.full_name < b.full_name)
          return 1 if (a.full_name > b.full_name)
          return 0
        callback.success.call(null, users) if callback? and callback.success?
  setUsers: (users, callback = {}) =>
    @db.view "#{@databaseName}/users",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (data) =>
        allUsers = []
        for user in users
          oneUser =
            type: "user"
            content: user
          if data.total_rows
            oldUser = _.find data.rows, (u) ->
              u.doc.content.id is user.id
            if oldUser
              oneUser._id = oldUser.doc._id
              oneUser._rev = oldUser.doc._rev
          allUsers.push oneUser
        @db.bulkSave {docs: allUsers},
          success: (data) =>
            users = (user.content for user in allUsers)
            callback.success.call(null, users) if callback? and callback.success?
  getTags: (callback = {}) =>
    @db.view "#{@databaseName}/tags",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (tags) =>
        tags = (_.extend({id: tag.id}, tag.value) for tag in tags.rows)
        callback.success.call(null, @_sortTags(tags)) if callback? and callback.success?
  addTag: (tag, callback = {}) =>
    doc = 
      type: "tag"
      content: tag
    @db.saveDoc doc,
      success: (data) =>
        callback.success.call(null, data) if callback? and callback.success?
  editTag: (docId, tag, callback = {}) =>
    @db.openDoc docId,
      success: (couchTag) =>
        couchTag.content = tag
        @db.saveDoc couchTag,
          success: (data) =>
            callback.success.call(null, data) if callback? and callback.success?
  deleteTag: (docId, callback = {}) =>
    @db.openDoc docId,
      success: (couchTag) =>
        @db.removeDoc couchTag,
          success: (data) =>
            callback.success.call(null, data) if callback? and callback.success?
  updateSortTags: (tags, sortIndex, callback = {}) =>
    @db.view "#{@databaseName}/tags",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (data) =>
        allTags = []
        for tag in tags
          oneTag =
            type: "tag"
            content: tag.toHash()
          if data.total_rows
            oldTag = _.find data.rows, (t) -> t.id is tag.get('id')
            if oldTag
              oneTag._id = oldTag.doc._id
              oneTag._rev = oldTag.doc._rev
              oneTag.content.sort_index = (_.indexOf(sortIndex, oneTag._id) + 1) if sortIndex? and _.indexOf(sortIndex, oneTag._id) isnt -1
          allTags.push oneTag
        @db.bulkSave {docs: allTags},
          success: (data) =>
            tags = (_.extend({id: tag._id}, tag.content) for tag in allTags)
            callback.success.call(null, @_sortTags(tags)) if callback? and callback.success?
  getMessagesByIds: (ids, callback = {}) ->
    ids = _.map ids, (id) -> [id]
    @db.view "#{@databaseName}/messages_by_id",
      include_docs: true
      keys: ids
      success: (data) =>
        messages = (msg for msg in data.rows)
        callback.success.call(null, messages) if callback? and callback.success?
  saveMessages: (messages, callback = {}) ->
    @db.bulkSave {docs: messages},
      success: (data) =>
        callback.success.call(null, data) if callback? and callback.success?