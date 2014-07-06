http = require 'http'

myexpress = ->
  makeApp = http.createServer (req, res) ->
    i = 0
    this.use (req, res) ->
      res.statusCode = 404
      do res.end

    next = (err)=>
      func = this.stack[i++]
      if err # 有 err 传入 'if next is called with an error
        if func
          next_func = this.stack[i++]
          next_func err, req, res, next
        else
          res.statusCode = 500
          res.end '500 - Internal Error'

      else # 无 err 传入 'when next is called without an error

        if func
          if func.length is 4
            do next
          else
            try
              func req, res, next
            catch e
              res.statusCode = 500
              res.end '500 - Internal Error'
        else
          do next

    do next

  makeApp.stack = []
  makeApp.use = (func) ->
    this.stack.push func

  return makeApp

module.exports = myexpress
