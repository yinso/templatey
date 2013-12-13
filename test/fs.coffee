fs = require '../src/fs'
path = require 'path'

describe 'load test', () ->
  it 'can load all files', (done) ->
    fs.loadPaths path.join(__dirname, '..'), {filter: '.coffee'}, (err, res) ->
      if err
        done err
      else
        done null

