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
    openIndex: Em.Route.transitionTo 'index'

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
      # EVENTS
      showGroup: Em.Route.transitionTo 'show'
      # STATES
      index: Em.Route.extend
        # SETUP
        route: '/'
        # FILTER
        beforeFilter: ->
          "login" unless App.currentUser
        connectOutlets: (router) ->
          router.get('applicationController').connectOutlet('groups', App.Group.find())
      show: Em.Route.extend
        # SETUP
        route: '/:group_id'
        # FILTER
        beforeFilter: ->
          "login" unless App.currentUser
        connectOutlets: (router, group) ->
          router.get('groupsController').connectOutlet('group', group)
        deserialize: (router, params) ->
          App.Group.findOne(params.group_id)
        serialize: (router, context) ->
          { group_id: (if context? then context.get("id") else null) }