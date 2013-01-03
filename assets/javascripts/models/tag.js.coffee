App.Tag = Ember.Object.extend
  isNew: false
  isEditing: false
  isDeleting: false
  # def values
  days: 1
  sort_index: 1
  daysChanged: (->
    days = @get("days").toString().replace(/[^\d]/g, "")
    days = 1 if parseInt(days) < 1 
    @set "days", days
  ).observes("days")
  toHash: ->
    @getProperties(['name', 'open_tag', 'close_tag', 'days', 'sort_index'])
App.Tag.reopenClass
  allTags: []
  prefillTags: (tags) ->
    @allTags.clear() if @allTags.length
    @allTags.addObjects tags.map((tag) ->
      App.Tag.create tag
    )
  addNewTag: ->
    @allTags.addObject(App.Tag.create
      isNew: true
      isEditing: true
    )
  removeTag: (tag) ->
    @allTags.removeObject tag
  find: ->
    @allTags
  findOne: (id) ->
    @allTags.find (t) => parseInt(t.get('id')) is parseInt(id)