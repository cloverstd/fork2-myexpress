express = require '../'
request = require 'supertest'
expect = (require 'chai').expect
http = require 'http'


describe 'app', ->
  app = do express

  describe 'create http server', ->
    before (done) ->
      server = http.createServer app
      server.listen 4000
      do done

    it 'responds to /foo with 404', (done) ->
      request app
        .get '/foo'
        .expect 404
        .end done

  describe '#listen', ->
    port = 7000
    server = undefined

    before (done) ->
      server = app.listen port, done

    it 'should return an http.Server', ->
      (expect server).to.be.instanceof http.Server

    it 'responds to /foo with 404', (done) ->
      request "http://localhost:#{port}"
        .get '/foo'
        .expect 404
        .end done
