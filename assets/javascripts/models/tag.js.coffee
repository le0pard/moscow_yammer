App.Tag = Ember.Object.extend
  isNew: false
  isEditing: false
  isDeleting: false
  daysChanged: (->
    @set "days", @get("days").toString().replace(/[^\d]/g, "")
  ).observes("days")
App.Tag.reopenClass
  allTags: []
  prefillTags: (tags) ->
    @allTags.clear() if @allTags.length
    @allTags.addObjects tags.map((tag) ->
      App.Tag.create tag
    )
  find: ->
    @allTags
  findOne: (id) ->
    @allTags.find (t) =>
      parseInt(t.get('id')) is parseInt(id)