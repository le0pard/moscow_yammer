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
        # SETUP
        route: '/:group_id'
        # FILTER
        beforeFilter: ->
          "login" unless App.currentUser
        connectOutlets: (router, group) ->
          groupsController = router.get('groupsController')
          groupsController.setActiveGroup(group)
          groupsController.connectOutlet('group', group)
          groupsController.connectOutlet('sidebar', 'groupSidebar', group)
        deserialize: (router, params) ->
          App.Group.findOne(params.group_id)
        serialize: (router, context) ->
          { group_id: (if context? then context.get("id") else null) }
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