async = require 'async'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'

loadPaths = (rootPath, options, cb) ->
  if arguments.length == 2
    cb = options
    options = {}
  result = []
  filterPath = (filePath) ->
    extname = path.extname(filePath)
    if options.filter instanceof Array
      if _.contains(options.filter, extname)
        result.push filePath
    else if typeof(options.filter) == 'string'
      if extname == options.filter
        result.push filePath
    else
      result.push filePath
  makeTask = (filePath) ->
    relPath = path.relative(rootPath, filePath)
    (cb) ->
      fs.stat filePath, (err, stat) ->
        if err
          cb err
        else if stat.isDirectory()
          helper filePath, (err, res) ->
            if err
              cb err
            else
              cb null, res
        else
          filterPath relPath
          cb null, relPath
  makeTasks = (dirName, files) ->
    for fileName in files
      makeTask path.join dirName, fileName
  helper = (dirPath, cb) ->
    fs.readdir dirPath, (err, files) ->
      if err
        cb err
      else
        async.parallel makeTasks(dirPath, files), cb
  helper rootPath, (err, res) ->
    if err
      cb err
    else
      cb null, result

fs.loadPaths = loadPaths

module.exports = fs
