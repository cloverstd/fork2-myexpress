makeRoute = (verb, handler) ->
  verb = verb.toUpperCase()
  (req, res, next) ->
    if req.method.toUpperCase() is verb
      handler req, res, next
    else
      do next


module.exports = makeRoute
