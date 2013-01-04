App.TagsView = Em.View.extend
  templateName: 'tags'
  didInsertElement: ->
    $("#tagsList").sortable
      axis: 'y'
      placeholder: 'ui-state-highlight'
      update: (event) =>
        objects = $("#tagsList li")
        objectIds = _.compact($(object).data('tag-id') for object in objects)
        App.db.updateSortTags App.Tag.find(), objectIds,
          success: (tags) =>
            App.Tag.prefillTags(tags)
    .disableSelection()