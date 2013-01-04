App.GroupTagsController = Em.ArrayController.extend
  setActiveTag: (selectedTag = null) ->
    activated = App.Tag.allTags.find (tag) => tag.get('isActive') is true
    activated.set('isActive', false) if activated?
    App.GroupTagsController.currentSelectedTag = selectedTag
    App.GroupTagsController.currentSelectedTag.set('isActive', true) if App.GroupTagsController.currentSelectedTag?

App.GroupTagsController.reopenClass
  currentSelectedTag: null