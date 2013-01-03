App.TagsView = Em.View.extend
  templateName: 'tags'
  didInsertElement: ->
    App.db.getTags
      success: (tags) =>
        App.Tag.prefillTags(tags)