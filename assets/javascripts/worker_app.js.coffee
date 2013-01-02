document = window = null

Worker =
  user: null
  yamRequest: null
  start: (data, callback = {}) ->
    Worker.user = data.user
    callback.complete.call(null, "done")
  getXmlHttp: ->
    xmlhttp = undefined
    try
      xmlhttp = new ActiveXObject("Msxml2.XMLHTTP")
    catch e
      try
        xmlhttp = new ActiveXObject("Microsoft.XMLHTTP")
      catch E
        xmlhttp = false
    xmlhttp = new XMLHttpRequest()  if not xmlhttp and typeof XMLHttpRequest isnt "undefined"
    xmlhttp
  sendRequest: (callback = {}) ->
    xmlhttp = Worker.getXmlHttp()
    xmlhttp.open "GET", "https://www.yammer.com/api/v1/groups.json", true
    xmlhttp.withCredentials = true
    xmlhttp.setRequestHeader 'Content-Type', 'application/x-www-form-urlencoded'
    xmlhttp.setRequestHeader 'Accept', 'application/json, text/javascript, */*; q=0.01'
    xmlhttp.setRequestHeader 'Authorization', "Bearer #{Worker.user.access_token.token}"
    xmlhttp.onreadystatechange = ->
      callback.complete.call(null, xmlhttp.responseText) if xmlhttp.status is 200 and xmlhttp.readyState is 4
    xmlhttp.send()

#importScripts('https://assets.yammer.com/platform/yam.js')

self.addEventListener "message", ((e) ->
  Worker.start e.data,
    complete: (returnInfo) ->
      self.postMessage(returnInfo)
), false