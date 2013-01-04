Em.Route.reopen
  setup: ->
    if (beforeFilter = Em.get(@, 'beforeFilter'))? and (redirection = beforeFilter())?
      @router.transitionTo redirection
    else
      @connectOutlets.apply(@, arguments)

App.Router = Em.Router.extend
  enableLogging: true
  location: 'hash'
  root: Em.Route.extend
    # EVENTS
    openIndex: Em.Route.transitionTo 'groups'
    openSettings: Em.Route.transitionTo 'settings'
    showGroup: Em.Route.transitionTo 'groups.show'
    # ROUTE
    index: Em.Route.extend
      # SETUP
      route: '/'
      redirectsTo: 'groups'
    login: Em.Route.extend
      # SETUP
      route: '/login'
      initialState: 'index'
      index: Em.Route.extend
        # SETUP
        route: '/'
        # FILTER
        beforeFilter: ->
          "groups" if App.currentUser
        connectOutlets: (router) ->
          router.get('applicationController').connectOutlet('login')
    groups: Em.Route.extend
      # SETUP
      route: '/groups'
      initialState: 'index'
      # STATES
      index: Em.Route.extend
        # SETUP
        route: '/'
        # FILTER
        beforeFilter: ->
          "login" unless App.currentUser
        connectOutlets: (router) ->
          App.Router.initGroups(router)
          router.get('groupsController').connectOutlet('mainHelp')
      show: Em.Route.extend
        # EVENTS
        showTag: Em.Route.transitionTo 'tag'
        # SETUP
        route: '/:group_id'
        initialState: 'index'
        connectOutlets: (router, group) ->
          groupsController = router.get('groupsController')
          groupsController.setActiveGroup(group)
          groupsController.connectOutlet('group', group)
          groupsController.connectOutlet('sidebar', 'groupSidebar', group)
          router.get('groupController').connectOutlet('tags', 'groupTags', App.Tag.find())
          router.get('groupController').connectOutlet('messages', App.Message.find())
        deserialize: (router, params) ->
          App.Group.findOne(params.group_id)
        serialize: (router, context) ->
          { group_id: (if context? then context.get("id") else null) }
        index: Em.Route.extend
          # SETUP
          route: '/'
          # FILTER
          beforeFilter: ->
            "login" unless App.currentUser
          connectOutlets: (router) ->
            router.get('groupTagsController').setActiveTag()
        tag: Em.Route.extend
          # SETUP
          route: '/:tag_id'
          # FILTER
          beforeFilter: ->
            "login" unless App.currentUser
          connectOutlets: (router, tag) ->
            router.get('groupTagsController').setActiveTag(tag)
            router.get('groupController').connectOutlet('messages', App.Message.find())
          deserialize: (router, params) ->
            App.Tag.findOne(params.tag_id)
          serialize: (router, context) ->
            { 
              tag_id: (if context? then context.get("id") else null), 
              group_id: (if App.GroupsController.currentSelectedGroup? then App.GroupsController.currentSelectedGroup.get('id') else null) 
            }
    settings: Em.Route.extend
      # SETUP
      route: '/settings'
      initialState: 'index'
      # STATES
      index: Em.Route.extend
        # SETUP
        route: '/'
        # FILTER
        beforeFilter: ->
          "login" unless App.currentUser
        connectOutlets: (router) ->
          App.Router.initGroups(router)
          router.get('groupsController').connectOutlet('settings')
          router.get('settingsController').connectOutlet('tags', App.Tag.find())

App.Router.reopenClass
  initGroups: (router) ->
    router.get('applicationController').connectOutlet('groups', App.Group.find())
    router.get('groupsController').setActiveGroup()