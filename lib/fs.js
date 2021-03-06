// Generated by CoffeeScript 1.4.0
(function() {
  var async, fs, loadPaths, path, _;

  async = require('async');

  fs = require('fs');

  path = require('path');

  _ = require('underscore');

  loadPaths = function(rootPath, options, cb) {
    var filterPath, helper, makeTask, makeTasks, result;
    if (arguments.length === 2) {
      cb = options;
      options = {};
    }
    result = [];
    filterPath = function(filePath) {
      var extname;
      extname = path.extname(filePath);
      if (options.filter instanceof Array) {
        if (_.contains(options.filter, extname)) {
          return result.push(filePath);
        }
      } else if (typeof options.filter === 'string') {
        if (extname === options.filter) {
          return result.push(filePath);
        }
      } else {
        return result.push(filePath);
      }
    };
    makeTask = function(filePath) {
      var relPath;
      relPath = path.relative(rootPath, filePath);
      return function(cb) {
        return fs.stat(filePath, function(err, stat) {
          if (err) {
            return cb(err);
          } else if (stat.isDirectory()) {
            return helper(filePath, function(err, res) {
              if (err) {
                return cb(err);
              } else {
                return cb(null, res);
              }
            });
          } else {
            filterPath(relPath);
            return cb(null, relPath);
          }
        });
      };
    };
    makeTasks = function(dirName, files) {
      var fileName, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = files.length; _i < _len; _i++) {
        fileName = files[_i];
        _results.push(makeTask(path.join(dirName, fileName)));
      }
      return _results;
    };
    helper = function(dirPath, cb) {
      return fs.readdir(dirPath, function(err, files) {
        if (err) {
          return cb(err);
        } else {
          return async.parallel(makeTasks(dirPath, files), cb);
        }
      });
    };
    return helper(rootPath, function(err, res) {
      if (err) {
        return cb(err);
      } else {
        return cb(null, result);
      }
    });
  };

  fs.loadPaths = loadPaths;

  module.exports = fs;

}).call(this);
