MoscowYammerDB = "moscow_yammer"

couchapp = require('couchapp')
path = require('path')

ddoc =
  _id: "_design/#{MoscowYammerDB}"
  rewrites: [
    from: "/"
    to: "index.html"
  ,
    from: "/#{MoscowYammerDB}"
    to: "../../"
  ,
    from: "/#{MoscowYammerDB}/*"
    to: "../../*"
  ,
    from: "/*"
    to: "*"
  ]

ddoc.views = {}
ddoc.views.groups = 
  map: (doc) ->
    emit [doc.content.id], doc.content if doc.type and doc.type is "group"
ddoc.views.users = 
  map: (doc) ->
    emit [doc.content.id], doc.content if doc.type and doc.type is "user"
ddoc.views.tags = 
  map: (doc) ->
    emit [doc._id], doc.content if doc.type and doc.type is "tag"
ddoc.views.messages_by_id = 
  map: (doc) ->
    emit [doc.content.id], doc.content if doc.type and doc.type is "message"
ddoc.views.messages_by_group = 
  map: (doc) ->
    return false unless doc.type and doc.type is "message"
    created_at = (new Date()).getTime()
    try
      created_at = Date.parse(doc.content.last_message.created_at)
    catch error
      created_at = (new Date()).getTime()
    emit [doc.content.group_id, created_at], doc.content
ddoc.views.messages_by_group_and_tag = 
  map: (doc) ->
    return false unless doc.type and doc.type is "message"
    return false unless doc.content.all_tags and doc.content.all_tags.length
    created_at = (new Date()).getTime()
    try
      created_at = Date.parse(doc.content.last_message.created_at)
    catch error
      created_at = (new Date()).getTime()
    for tag in doc.content.all_tags
      emit [doc.content.group_id, tag, created_at], doc.content

ddoc.validate_doc_update = (newDoc, oldDoc, userCtx) ->
  throw "Only admin can delete documents on this database."  if newDoc._deleted is true and userCtx.roles.indexOf("_admin") is -1

couchapp.loadAttachments ddoc, path.join(__dirname, "attachments")
module.exports = ddoc