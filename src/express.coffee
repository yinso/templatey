Service = require './service'
_ = require 'underscore'

middleware = (options) ->
  Service.loadTemplates options.rootPath, (err, res) ->
    if err
      throw e
  service = Service.make options
  process.on 'exit', () ->
    service.close()
  (req, res, next) ->
    onSendMail = (evt) ->
      args = _.extend {}, options.args, evt.args
      console.log 'onSendMail', args, evt
      service.send args, evt.data, () ->
    res.on 'sendMail', onSendMail
    res.once 'finish', () ->
      res.removeListener 'sendMail', onSendMail
    next()

module.exports = middleware
