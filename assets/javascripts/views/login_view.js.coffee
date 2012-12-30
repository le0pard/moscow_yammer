App.LoginView = Em.View.extend
  templateName: 'login'
  didInsertElement: ->
    #@_super()
    yam.connect.loginButton @$("#yammerLogin"), (resp) =>
      @$("#yammerLogin").text("Done. Please, reload page.") if resp.authResponse