http = require "http"

module.exports = ->
  app = (req, res, appNext) ->

    currentIndex = 0

    middlewareNext = (err) ->
      middleware = app.stack[currentIndex++]

      if err # when middlewareNext is called with an error
        if middleware # middleware is not undefined
          if middleware.length is 4 # error handler middleware
            middleware err, req, res, middlewareNext
          else
            next err
        else # middleware is undefined
          if appNext
            appNext err
          res.writeHead 500
          res.end "500 - Internal Error"
      else # when middlewareNext is called without an error
        if middleware # middleware is not undefined
          if middleware.length is 4 # error handler middleware
            do middlewareNext
          try
            middleware req, res, middlewareNext
          catch e
            middlewareNext e
        else # middleware is undefined
          if appNext
            appNext err
          res.writeHead 404
          res.end "404 - Not Found #{req.url}"

    do middlewareNext


  app.listen = ->
    server = http.createServer this
    server.listen.apply server, arguments

  app.stack = []
  app.use = (middleware) ->
    app.stack.push middleware

  return app
