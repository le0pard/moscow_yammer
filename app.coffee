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

ddoc.validate_doc_update = (newDoc, oldDoc, userCtx) ->
  throw "Only admin can delete documents on this database."  if newDoc._deleted is true and userCtx.roles.indexOf("_admin") is -1

couchapp.loadAttachments ddoc, path.join(__dirname, "attachments")
module.exports = ddoc