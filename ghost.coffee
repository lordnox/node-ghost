fs    = require 'fs'
async = require 'async'
Path  = require 'path'

remove = (path, fn) ->
  console.log "removing #{path}"
  fs.stat path, (err, stat) ->
    return fn err if err
    return removeFile path, fn if stat.isFile()
    return removeDirectory path, fn if stat.isDirectory()
    fn null, path
removeFile = (path, fn) ->
  fs.unlink path, fn
removeDirectory = (path, fn) ->
  fs.readdir path, (err, files) ->
    return fn err if err
    paths = files.map (file) -> Path.join path, file
    async.mapSeries paths, remove, (err, result) ->
      return fn err if err
      fs.rmdir path, fn

removeSpecial = (path, fn) ->
  fs.readdir path, (err, files) ->
    paths = files
      .filter( (file) -> file isnt 'node_modules' and file[0] isnt '.' )
      .map( (file) -> Path.join path, file )
    async.mapSeries paths, remove, fn

### GHOST
  * options-only
  ghost
    fn: ->
    path: '/some/path'
  * options & callback
  ghost
    path: '/some/path'
  , ->
  *
###
ghost = (path, fn) ->
  if typeof path is 'function'
    options = fn: path
  if typeof path is 'object'
    options = path

  options.fn    = options.fn or fn
  options.path  = options.path or process.cwd()

  removeSpecial options.path, options.fn


module.exports = ghost
