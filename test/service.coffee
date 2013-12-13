Service = require '../src/service'
path = require 'path'
handlebars = require 'handlebars'
bean = require 'coffee-bean'
read = require 'read'

markdown = 'Hi {{ firstName }}, how are you doing today? Cheers, {{ myName }}'

expectedHTML = '<p>Hi Alice, how are you doing today? Cheers, Bob</p>\n'

expectedText = 'Hi Alice, how are you doing today? Cheers, Bob'

data = [
  {
    firstName: 'Alice'
    email: '<toEmail></toEmail>'
    myName: 'Bob'
  }
  {
    firstName: 'Jen'
    email: '<toEmail></toEmail>'
    myName: 'Mary'
  }
]

args =
  from: '<fromEmail></fromEmail>'
  subject: 'test email'
  type: 'markdown'
  template: markdown

args1 =
  from: '<fromEmail></fromEmail>'
  subject: 'test email'
  template: 'msg/forgetPasswordResult'

data1 = [
  {
    email: '<toEmail></toEmail>'
    siteName: 'test.com'
    resetUrl: 'test.com/reset/1'
    ourTitle: 'The Test.com Team'
  }
]

config =
  type: 'SMTP'
  service: 'Gmail'
  auth:
    user: '<login></login>'
    pass: '<pass></pass>'

service = null

configure = (user, pass, fromEmail, toEmail) ->
  console.log "configure..."
  config.auth.user = user
  config.auth.pass = pass
  args.from = fromEmail
  args1.from = fromEmail
  data[0].email = toEmail
  data[1].email = toEmail
  data1[0].email = toEmail
  service = new Service config
  console.log "configure done... continue with test..."

sameAs = (data, prev) ->
  if data == 'y' or data == 'Y'
    prev
  else
    data

describe 'template test', () ->
  it 'can prompt for auth', 50000, (done) ->
    console.log '********************************************************************************'
    console.log "Email test utilizes your credential for testing (so you can see the mails being sent)"
    console.log "This is not captured beyond the test session"
    console.log "Feel free to examine the code for security"
    console.log ""
    console.log '********************************************************************************'
    read {prompt: 'Your gmail login (not captured): '}, (err, login) ->
      if err
        done err
      else
        read {prompt: 'Your gmail password (not captured): ', silent: true}, (err, passwd) ->
          if err
            done err
          else
            read {prompt: 'from email (y if same as login): '}, (err, fromEmail) ->
              if err
                done err
              else
                read {prompt: 'to email (y if same as from email): '}, (err, toEmail) ->
                  if err
                    done err
                  else
                    fromEmail = sameAs fromEmail, login
                    toEmail = sameAs toEmail, fromEmail
                    configure login, passwd, fromEmail, toEmail
                    done null

  it 'can load template', (done) ->
    Service.loadTemplates path.join(__dirname, '../views'), (err, res) ->
      if err
        done err
      else
        done null

  it 'can transform ', (done) ->
    try

      {html, text} = service.transform {template: markdown, type: 'markdown', layout: false}, data[0]
      test.equal html, expectedHTML
      test.equal text, expectedText
      done null
    catch e
      done e

  it 'can send one email', 0, (done) ->
    try
      service.send args, data[0], (err, res) ->
        if err
          done err
        else
          done null
    catch e
      done e

  it 'can send multiple emails', 0, (done) ->
    try
      service.send args1, data1, (err, res) ->
        if err
          done err
        else
          done null
    catch e
      done e

  it 'can close', (done) ->
    try
      service.close()
      done null
    catch e
      done e