document = window = null

Worker =
  user: null
  yamRequest: null
  start: (data, callback = {}) ->
    Worker.user = data.user
    callback.complete.call(null, "text")

#importScripts('https://assets.yammer.com/platform/yam.js')

self.addEventListener "message", ((e) ->
  Worker.start e.data,
    complete: (returnInfo) ->
      self.postMessage(returnInfo)
), false