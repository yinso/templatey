# Templatey - A Simple Email Template System for NodeJS

Template is a simple email template system that allows you to write templates in handlebars just like you would
write templates for your websites, then you just pass the appropriate data into the template for email generation.

## Installation

    npm install templatey

## Usage

You can have a directory holding the templates written with handlebars ending in `.hbs`. What this means is that
you can share the template directories for your express app with templatey.

You can also use ad hoc templates. Below shows how to use templates both ways.

### Initialize the Template Service

    var service = Template.make(options);

The `option` objects passed in will instantiate the appropriate service. `Templatey` uses [`NodeMailer`](http://nodemailer.com)
for sending emails, so any combination of appropriate parameters expected by `NodeMailer` will work here.

Examples of some `NodeMailer` parameters are

    {
      "type": "SMTP",
      "service": "Gmail",
      "auth": {
        "user": <gmail_user_name>,
        "pass": <gmail_password>
      }
    }

Besides the `NodeMailer options, the following are additional options expected by `templatey`.

* `rootPath` - points to the root folder of your predefined hbs templates
* `args` - default arguments for the emails you would send, for example:

    {
      "from": <the_default_email_address>,
      "subject": <the_default_subject>
      ...
    }

### Sending Emails

To send an email, use the `service` object that you have instantiated.

    service.send(args, data, function(err) { ... });

The `args are the default settings for your email, and the `data` are what would be used in template merging.

Args are similar to the `options.args` passed into `templatey.make`, with any email parameters that you would
want to have as default.

Here are some examples that you can use (basically the same as `NodeMailer`)

    {
      "from": <from_email_address>
      , "to": <to_email_address>
      , "subject": <subject_of_the_email>
      ...
    }

### Using Predefined Templates

To use predefined template, have a template parameter to be a relative path of the specific pre-defined template you
are instantiating.

For example, let's say we have the the following folder structure for templates:

    /
      /msg
         forgetPasswordResult.hbs
         forgetUserResult.hbs
      layout.hbs

To refer to `forgetUserResult.hbs`, pass in

    {
      ...
      "template": "msg/forgetUserResult"
      ...
    }

### Using Ad Hoc Templates

To pass in an ad hoc template, just use the `template` parameter to hold the particular template, and then simply
add a `type` parameter to specify the type of the template.

    {
      ...
      "template": "This is a markdown message. Hello, {{ user.name }}.",
      "type": "markdown"
      ...
    }

Currently, `templatey` handles `markdown` and `html` for the templates.

### The Data Parameter

The data object is basically any data that your template would expect, plus a couple of parameters that'll be
merged into the args object.

    {
      "email": <for_replacing_to_email_address>
      "subject": <if specified will replace subject in the arg>
      ... anything else your templates expect...
    }

If you pass in an array - it'll be iterated through to create multiple emails.

### Express Middleware

You can use `templatey` with [`express`](http://expressjs.com).

    var templatey = require('templatey');

    app.use(templatey.middleware(options)); // option is the same as the description above.

The middleware will subscribe to a `sendMail` event raised through `res` object, so to send email, you just do the
following in your route.

    function(req, res) {
      res.emit('sendMail', {args: <the_args_param>, data: <the_data_param});
    }



