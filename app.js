// Generated by CoffeeScript 1.4.0
(function() {
  var MoscowYammerDB, couchapp, ddoc, path;

  MoscowYammerDB = "moscow_yammer";

  couchapp = require('couchapp');

  path = require('path');

  ddoc = {
    _id: "_design/" + MoscowYammerDB,
    rewrites: [
      {
        from: "/",
        to: "index.html"
      }, {
        from: "/" + MoscowYammerDB,
        to: "../../"
      }, {
        from: "/" + MoscowYammerDB + "/*",
        to: "../../*"
      }, {
        from: "/*",
        to: "*"
      }
    ]
  };

  ddoc.views = {};

  ddoc.views.groups = {
    map: function(doc) {
      if (doc.type && doc.type === "group") {
        return emit([doc.content.id], doc.content);
      }
    }
  };

  ddoc.views.users = {
    map: function(doc) {
      if (doc.type && doc.type === "user") {
        return emit([doc.content.id], doc.content);
      }
    }
  };

  ddoc.views.tags = {
    map: function(doc) {
      if (doc.type && doc.type === "tag") {
        return emit([doc._id], doc.content);
      }
    }
  };

  ddoc.views.messages_by_id = {
    map: function(doc) {
      if (doc.type && doc.type === "message") {
        return emit([doc.content.id], doc.content);
      }
    }
  };

  ddoc.views.messages_by_group = {
    map: function(doc) {
      var created_at;
      if (!(doc.type && doc.type === "message")) {
        return false;
      }
      created_at = (new Date()).getTime();
      try {
        created_at = Date.parse(doc.content.last_message.created_at);
      } catch (error) {
        created_at = (new Date()).getTime();
      }
      return emit([doc.content.group_id, created_at], doc.content);
    }
  };

  ddoc.views.messages_by_group_and_tag = {
    map: function(doc) {
      var created_at, tag, _i, _len, _ref, _results;
      if (!(doc.type && doc.type === "message")) {
        return false;
      }
      if (!(doc.content.all_tags && doc.content.all_tags.length)) {
        return false;
      }
      created_at = (new Date()).getTime();
      try {
        created_at = Date.parse(doc.content.last_message.created_at);
      } catch (error) {
        created_at = (new Date()).getTime();
      }
      _ref = doc.content.all_tags;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tag = _ref[_i];
        _results.push(emit([doc.content.group_id, tag, created_at], doc.content));
      }
      return _results;
    }
  };

  ddoc.validate_doc_update = function(newDoc, oldDoc, userCtx) {
    if (newDoc._deleted === true && userCtx.roles.indexOf("_admin") === -1) {
      throw "Only admin can delete documents on this database.";
    }
  };

  couchapp.loadAttachments(ddoc, path.join(__dirname, "attachments"));

  module.exports = ddoc;

}).call(this);
