App.TagsController = Em.ArrayController.extend
  _closeForms: (tag) ->
    tag.setProperties({isEditing: false, isDeleting: false}) if tag?
  openEditMode: (e) ->
    tag = e.context
    tag.setProperties({isEditing: true, isDeleting: false}) if tag?
  openDeleteMode: (e) ->
    tag = e.context
    tag.setProperties({isEditing: false, isDeleting: true}) if tag?
  closeAllMode: (e) ->
    tag = e.context
    @_closeForms(tag)
  addNewTag: (e) ->
    App.Tag.addNewTag()
  deleteNewTag: (e) ->
    tag = e.context
    App.Tag.removeTag(tag) if tag?
  addTag: (e) ->
    tag = e.context
    return null unless tag?
    App.db.addTag tag.toHash(),
      success: (data) =>
         tag.setProperties
          id: data.id
          isEditing: false
          isNew: false
          isDeleting: false
  editTag: (e) ->
    tag = e.context
    return null unless tag?
    App.db.editTag tag.get('id'), tag.toHash(),
      success: =>
        @_closeForms(tag)
  deleteTag: (e) ->
    tag = e.context
    return null unless tag?
    App.db.deleteTag tag.get('id'),
      success: =>
        App.Tag.removeTag(tag)