http = require "http"

module.exports = ->
  app = (req, res) ->
    res.writeHead 404
    res.end("404 - Not Found #{req.url}")

  app.listen = ->
    server = http.createServer this
    server.listen.apply server, arguments

  return app
