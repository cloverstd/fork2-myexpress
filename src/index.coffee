http = require 'http'

module.exports = ->
  app = (req, res) ->

    i = 0
    next = (err) ->
      func = app.stack[i++]
      if err
        if func
          if func.length is 4
            func err, req, res, next
          else
            next err
        else
          res.statusCode = 500
          res.end '500 - Internal Error'
      else # next without err
        if func
          if func.length is 4
            do next
          else
            try
              func req, res, next
            catch e
              next e

    do next
    res.statusCode = 404
    res.end '404 - Not Found'

  app.listen = ->
    server = http.createServer this
    server.listen.apply server, arguments

  app.stack = []
  app.use = (func) ->
    if func.hasOwnProperty 'stack'
      this.stack.push.apply this.stack, func.stack
    else
      this.stack.push func


  return app
