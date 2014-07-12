path2RegExp = require 'path-to-regexp'

class Layer
  constructor: (@prefixPath, @handle) ->

  match: (path) ->
    path = decodeURIComponent path

    keys = []
    re = path2RegExp @prefixPath, keys, {end: false}

    rv = re.exec path

    if not rv
      return undefined

    result =
      path: rv[0]
      params: {}

    rv = rv[1...]

    for i in [0...rv.length]
      result.params[keys[i].name] = rv[i]

    return result

module.exports = Layer
