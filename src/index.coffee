http = require 'http'

myexpress = ->

 http.createServer (req, res) ->

    res.statusCode = 404
    do res.end

module.exports = myexpress
