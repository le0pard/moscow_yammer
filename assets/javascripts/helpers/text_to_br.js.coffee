Ember.Handlebars.registerHelper 'textToBr', (context, options) ->
  normalized = Ember.Handlebars.normalizePath(@, context, options.data)
  msg = normalized.root
  new Handlebars.SafeString(msg.body.plain.replace(/\n/g, "<br />"))