http = require 'http'
Layer = require './layer'

module.exports = ->
  app = (req, res) ->

    i = 0
    next = (err) ->
      layer = app.stack[i++]
      if !layer
        if err
          res.statusCode = 500
          res.end '500 - Internal Error'
        return

      rv = layer.match req.url
      if !rv
        req.params = {}
        next err
      else
        req.params = rv.params

      func = layer.handle

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
  app.use = (path, func)->
    if arguments.length is 2
      layer = new Layer(path, func)
      this.stack.push layer

    else if arguments.length is 1
      func = path
      layer = new Layer('/', func)
      if func.hasOwnProperty 'stack'
        this.stack.push.apply this.stack, func.stack
      else
        this.stack.push layer


  return app
