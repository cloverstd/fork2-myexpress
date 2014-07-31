http = require "http"
Layer = require '../lib/layer'
makeRoute = require '../lib/route'
methods = require "methods"

module.exports = ->
  app = (req, res, appNext) ->

    currentIndex = 0

    originalURL = req.url
    middlewareNext = (err) ->
      layer = app.stack[currentIndex++]

      if layer
        rv = layer.match req.url
        if rv
          middleware = layer.handle
          req.params = rv.params
        else
          middlewareNext err

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
            if typeof middleware.handle is "function" # sub app
              subPath = req.url.substring req.url.indexOf("/", 1)
              originalURL = req.url
              req.url = subPath

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
  app.use = (path, middleware) ->
    if arguments.length is 1
      middleware = path
      path = '/'

    layer = new Layer(path, middleware)
    app.stack.push layer

  app.handle = (req, res, appNext) ->
    app req, res, appNext

  methods.forEach (method) ->
    app[method] = (path, handle) ->
      handle = makeRoute method, handle
      layer = new Layer(path, handle)
      app.stack.push layer


  return app
