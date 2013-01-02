root = global ? window
class root.CouchDB
  constructor: (@databaseName, @user) ->
    @db = $.couch.db(@databaseName)
    @db.compact
      success: (data) =>
        # done
  getGroups: (callback = {}) =>
    @db.view "#{@databaseName}/groups",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (allGroups) =>
        groups = (group.value for group in allGroups.rows)
        groups = groups.sort (a, b) =>
          return -1 if (a.full_name < b.full_name)
          return 1 if (a.full_name > b.full_name)
          return 0
        callback.success.call(null, groups) if callback? and callback.success?
  setGroups: (groups, callback = {}) =>
    @db.view "#{@databaseName}/groups",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (data) =>
        allGroups = []
        for group in groups
          oneGroup = {}
          oneGroup.type = "group"
          oneGroup.content = group
          if data.total_rows
            oldGroup = _.find data.rows, (g) ->
              g.doc.content.id is group.id
            if oldGroup
              oneGroup._id = oldGroup.doc._id
              oneGroup._rev = oldGroup.doc._rev
          allGroups.push oneGroup
        @db.bulkSave {docs: allGroups},
          success: (data) =>
            groups = (group.content for group in data)
            groups = groups.sort (a, b) =>
              return -1 if (a.full_name < b.full_name)
              return 1 if (a.full_name > b.full_name)
              return 0
            callback.success.call(null, groups) if callback? and callback.success?
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
          oneUser = {}
          oneUser.type = "user"
          oneUser.content = user
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