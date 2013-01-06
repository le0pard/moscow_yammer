Ember.Handlebars.registerHelper 'getCurrentTag', (context, options) ->
  if App.GroupTagsController.currentSelectedTag?
    new Handlebars.SafeString(App.GroupTagsController.currentSelectedTag.get('open_tag'))
  else
    normalized = Ember.Handlebars.normalizePath(@, context, options.data)
    msg = normalized.root
    allTags = (tag.substring(1) for tag in msg.get('all_tags'))
    for tag in App.Tag.find()
      return new Handlebars.SafeString(tag.get('open_tag').toLowerCase()) if _.indexOf(allTags, tag.get('open_tag').toLowerCase()) isnt -1
    "Not found"