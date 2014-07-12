class Layer
  constructor: (@prefixPath, @handle) ->


  match: (path) ->
    pattern = new RegExp("^#{@prefixPath}((/.+)?|/?)")

    if not path.match pattern
      return undefined

    {path: @prefixPath}


module.exports = Layer
