class Layer
  constructor: (@prefixPath, @handle) ->

  match: (path) ->
    if @prefixPath is '/'
      key = "^/.+"
    else
      key = "^#{@prefixPath}(/.+)?$"
    pattern = new RegExp(key)

    if path.match pattern
      return {path: @prefixPath}

    return undefined


module.exports = Layer
