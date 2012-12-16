var MoscowYammerDB = "moscow_yammer";

 var couchapp = require('couchapp')
  , path = require('path')
  ;

ddoc = 
  { _id:'_design/' + MoscowYammerDB
  , rewrites : 
    [ {from:"/", to:'index.html'}
    , {from:"/" + MoscowYammerDB, to:'../../'}
    , {from:"/" + MoscowYammerDB + "/*", to:'../../*'}
    , {from:"/*", to:'*'}
    ]
  }
  ;

ddoc.views = {};

ddoc.validate_doc_update = function (newDoc, oldDoc, userCtx) {   
  if (newDoc._deleted === true && userCtx.roles.indexOf('_admin') === -1) {
    throw "Only admin can delete documents on this database.";
  } 
}

couchapp.loadAttachments(ddoc, path.join(__dirname, 'attachments'));

module.exports = ddoc;