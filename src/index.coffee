http = require 'http'

myexpress = ->
  makeApp = http.createServer (req, res) ->
    i = 0
    this.use (req, res) ->
      res.statusCode = 404
      do res.end

    next = =>
      func = this.stack[i++]
      if func
        func req, res, next

    do next

  makeApp.stack = []
  makeApp.use = (func) ->
    this.stack.push func

  return makeApp

module.exports = myexpress
