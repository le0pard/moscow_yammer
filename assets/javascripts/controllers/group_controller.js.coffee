App.GroupController = Em.ObjectController.extend
  updateGroupInfo: (e) ->
    #console.log e
    group = @get('content')
    #console.log group
    #console.log group.get('id')
    worker = new Worker('assets/worker.js')
    worker.addEventListener "message", ((e) ->
      console.log e.data
    ), false
    worker.postMessage
      user: App.currentUser