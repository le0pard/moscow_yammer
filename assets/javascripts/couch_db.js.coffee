root = global ? window
class root.CouchDB
  constructor: (@databaseName, @user) ->
    @db = $.couch.db(@databaseName)
  setGroups: (groups, callback = {}) =>
    @db.view "#{@databaseName}/groups",
      include_docs: true
      error: =>
        callback.success.call(null, []) if callback? and callback.success?
      success: (data) =>
        allGroups = []
        for group in groups
          if data.total_rows
            oldGroup = _.find data.rows, (g) ->
              g.doc.content.id is group.id
          else
            oldGroup = null
          oneGroup = {}
          oneGroup.type = "group"
          oneGroup.content = group
          if oldGroup
            oneGroup._id = oldGroup.doc._id
            oneGroup._rev = oldGroup.doc._rev
          allGroups.push oneGroup
        @db.bulkSave {docs: allGroups},
          success: (data) =>
            callback.success.call(null, (group.content for group in allGroups)) if callback? and callback.success?