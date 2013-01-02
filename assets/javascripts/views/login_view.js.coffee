App.LoginView = Em.View.extend
  templateName: 'login'
  didInsertElement: ->
    #@_super()
    yam.connect.loginButton @$("#yammerLogin"), (resp) =>
      if resp.authResponse
        @$("#yammerLogin").text("Done. Please, reload page.")
        location.reload()