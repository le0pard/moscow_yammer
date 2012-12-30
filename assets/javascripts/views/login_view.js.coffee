App.LoginView = Em.View.extend
  templateName: 'login'
  didInsertElement: ->
    #@_super()
    yam.getLoginStatus (response) =>
      if resp.authResponse
        console.log "logedin"
      else
        console.log "Not logedin"