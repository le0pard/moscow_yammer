App.Router = Em.Router.extend
  enableLogging: true
  location: 'hash'
  root: Em.Route.extend
    index: Em.Route.extend
      # SETUP
      route: '/'
      redirectsTo: 'groups'
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
        connectOutlets: (router) ->
          router.get('applicationController').connectOutlet('groups', App.Group.find())
      show: Em.Route.extend
        # SETUP
        route: '/:group_id'
        connectOutlets: (router, group) ->
          router.get('groupsController').connectOutlet('group', group)