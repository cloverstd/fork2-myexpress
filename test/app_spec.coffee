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

  describe '.use', ->
    app = undefined

    before (done) ->
      app = do express
      app.use (req, res, next) ->
        if req.url is "/hi"
          res.end 'hi'
      app.listen(done)

    it 'should be able to add middlewares to stack', (done) ->

      request(app)
        .get('/hi')
        .expect 200
        .end done

  describe 'calling middleware stack', ->
    app = undefined

    beforeEach ->
      app = new express()

    it 'Should be able to call a single middleware', (done) ->
      app.use (req, res, next) ->
        res.end 'hello from m1'

      do app.listen
      request(app)
        .get('/')
        .expect 200
        .expect 'hello from m1'
        .end done

    it 'Should be able to call `next` to go to the next middleware', (done) ->
      app.use (req, res, next) ->
        do next

      app.use (req, res, next) ->
        res.end 'hello from m2'

      app.listen(4001)
      do app.listen
      request(app)
        .get('/')
        .expect 200
        .expect 'hello from m2'
        .end done

    it 'Should 404 at the end of middleware chain', (done) ->
      app.use (req, res, next) ->
        do next

      app.use (req, res, next) ->
        do next

      app.listen(4002)
      do app.listen
      request(app)
        .get('/')
        .expect 404
        .end done


    it 'Should 404 if no middleware is added', (done) ->

      app.listen(4003)
      do app.listen
      request(app)
        .get('/')
        .expect 404
        .end done

  describe 'Implement Error Handling', ->
    app = undefined

    beforeEach ->
      app = do express


    it 'should return 500 for unhandled error', (done) ->
      app.use (req, res, next) ->
        next new Error 'boom!'

      do app.listen
      request(app)
        .get('/')
        .expect 500
        .end done

    it 'should return 500 for uncaught error', (done) ->
      app.use (req, res, next) ->
        throw new Error 'boom!'

      app.listen 4001
      request(app)
        .get('/')
        .expect 500
        .end done

    it 'should ignore error handlers when `next` is called without an error', (done) ->
      app.use (req, res, next) ->
        do next

      app.use (err, req, res, next) ->

      app.use (req, res, next) ->
        res.end 'm2'

      app.listen 4002
      request(app)
        .get('/')
        .expect 200
        .expect 'm2'
        .end done

    it 'should skip normal middlewares if `next` is called with an error', (done) ->
      app.use (req, res, next) ->
        next new Error 'boom!'

      app.use (req, res, next) ->

      app.use (err, req, res, next) ->
        res.end 'e1'

      app.listen 4003
      request(app)
        .get('/')
        .expect 200
        .expect 'e1'
        .end done
