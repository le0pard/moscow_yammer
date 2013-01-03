App.TagsController = Em.ArrayController.extend
  openEditMode: (e) ->
    tag = e.context
    tag.setProperties({isEditing: true, isDeleting: false}) if tag?
  openDeleteMode: (e) ->
    tag = e.context
    tag.setProperties({isEditing: false, isDeleting: true}) if tag?
  closeAllMode: (e) ->
    tag = e.context
    tag.setProperties({isEditing: false, isDeleting: false}) if tag?
  editTag: (e) ->
    tag = e.context
    console.log tag.get('name')