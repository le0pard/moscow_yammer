App.Router = Ember.Router.extend
  enableLogging: true
  location: 'hash'
  root: Ember.Route.extend
    index: Ember.Route.extend
      # SETUP
      route: '/'
      redirectsTo: 'groups'

    groups: Ember.Route.extend
      # SETUP
      route: '/groups'
      initialState: 'index'
      # EVENTS
      showThread: Ember.Route.transitionTo 'show'
      # STATES
      index: Ember.Route.extend
        # SETUP
        route: '/'
        connectOutlets: (router) ->
          router.get('applicationController').connectOutlet('groups', App.Group.find())