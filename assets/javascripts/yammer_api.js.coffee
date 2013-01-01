root = global ? window
class root.YammerApi
  getGroups: (callback = {}, summaryInfo = {data: [], page: 1}) =>
    yam.request
      url: "/api/v1/groups.json"
      method: "GET"
      dataType: "json"
      data: "page=#{summaryInfo.page}"
      success: (data) =>
        if data.length
          @getGroups(callback, {data: summaryInfo.data.concat(data), page: (summaryInfo.page + 1)})
        else
          callback.success.call(null, summaryInfo.data) if callback? and callback.success?
      error: =>
        callback.error.call(null) if callback? and callback.error?
    