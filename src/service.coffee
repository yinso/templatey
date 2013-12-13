handlebars = require 'handlebars'
mailer = require 'nodemailer'
markdown = require 'marked'
htmlToText = require 'html-to-text'
{EventEmitter} = require 'events'
async = require 'async'
_ = require 'underscore'
fs = require './fs'
path = require 'path'
mockquery = require 'mockquery'

class Service
  @transports: {}
  @templates: {}
  @loadTemplates: (rootPath, cb) ->
    makeTask = (filePath) ->
      (cb) ->
        fs.readFile path.join(rootPath, filePath), 'utf8', (err, data) ->
          if err
            cb err
          else
            try
              ext = path.extname(filePath)
              templateName = path.join(path.dirname(filePath), path.basename(filePath, ext))
              if ext == '.md'
                data = markdown data
              handlebars.registerPartial templateName, data
              Service.templates[templateName] = handlebars.compile(data)
              cb null, templateName
            catch e
              cb e
    asyncHelper = (files) ->
      for file in files
        makeTask file
    fs.loadPaths rootPath, {filter: ['.md', '.hbs']}, (err, files) ->
      if err
        cb err
      else
        async.parallel asyncHelper(files), cb
  @make: (config) ->
    if not config.hasOwnProperty('name')
      throw new Error("Service.make:config_must_have_name")
    name = config.name
    if @transports.hasOwnProperty(name)
      throw new Error("Service.make:transport_already_exists: #{name}")
    @transports[name] = new @ config
    @transports[name]
  constructor: (@config) ->
    process.on 'exit', @close
  transform: (args, data) ->
    htmlSource =
      if args.type == 'markdown'
        markdown(args.template)
      else
        args.template
    template =
      if @constructor.templates.hasOwnProperty(htmlSource)
        @constructor.templates[htmlSource]
      else
        handlebars.compile(htmlSource)
    html = template(data)
    if not args.hasOwnProperty('layout') or args['layout'] != false
      layoutTemplate = @constructor.templates[if typeof(args.layout) == 'string' then args.layout else 'layout']
      html = layoutTemplate {body: html}
    text = htmlToText.fromString(html, {wordwrap: 72})
    $ = mockquery.load html
    testTitle = $('title')
    if testTitle.length > 0
      {html: html, text: text, title: testTitle.html()}
    else
      {html: html, text: text}
  close: () =>
    if @transport
      @transport.close()
      delete @transport
  sendOne: (args, data, cb) ->
    try
      if not @transport
        @init()
      trans = @transform args, data
      args = _.extend {}, args, trans
      if data.email # this allows the email to be specified as part of the data!
        args.to = data.email
      if not args.to
        throw new Error("Service.send:to_address_is_missing")
      console.log 'Service.sendOne', args.to, args.from
      @transport.sendMail args, (err, res) ->
        if err
          cb err
        else
          cb null, res
    catch e
      cb e
  send: (args, data, cb) ->
    if data instanceof Array
      helper = (item, next) =>
        @sendOne args, item, next
      async.map data, helper, (err, reses) ->
        if err
          cb err
        else
          cb null, reses
    else
      @sendOne args, data, cb
  init: () ->
    @transport = mailer.createTransport @config.type or 'SMTP', @config

module.exports = Service
