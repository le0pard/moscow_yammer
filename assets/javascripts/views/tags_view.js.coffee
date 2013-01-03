App.TagsView = Em.View.extend
  templateName: 'tags'
  _fillTags: (tags) ->
    App.Tag.prefillTags(tags)
  didInsertElement: ->
    App.db.getTags
      success: @_fillTags
    $("#tagsList").sortable
      axis: 'y'
      placeholder: 'ui-state-highlight'
      update: (event) =>
        objects = $("#tagsList li")
        objectIds = _.compact($(object).data('tag-id') for object in objects)
        App.db.updateSortTags App.Tag.find(), objectIds
    .disableSelection()