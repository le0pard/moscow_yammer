App.ApplicationView = Em.View.extend
  templateName: 'application'
  didInsertElement: ->
    yam.getLoginStatus (response) ->
      return false unless response.authResponse? and response.authResponse is true
      $('.settings_buttons > a.settings_button_link').show()