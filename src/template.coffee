# Template renderer
handlebars = require 'handlebars'
async = require './utils/async' # From express-hbs
md5 = require 'md5-file'
configuration = require './utils/configuration'
{Promise, fs} = require './utils/dependencies'

# Hack from express-hbs
handlebars.registerAsyncHelper = (name, fn) ->
  @registerHelper name, (context, options) ->
    if options && fn.length > 2
      resolver = (arr, cb) ->
        fn.call @, arr[0], arr[1], cb
      return async.resolve resolver.bind(@), [context, options]
    return async.resolve fn.bind(@), context

handlebars.registerAsyncHelper 'asset', (name, cb) ->
  md5 "./template/assets/#{name}", (err, hash) ->
    throw err if err
    cb new handlebars.SafeString "/assets/#{name}?v=#{hash[0..7]}"

template = {}

reload = ->
  fs.readdirAsync './template/partials'
    .filter (file) -> file.endsWith '.hbs'
    .each (file) ->
      fs.readFileAsync "./template/partials/#{file}"
        .then (t) ->
          handlebars.registerPartial file, handlebars.compile t.toString()
    .all()
    .catch (e) -> ''
    .then -> fs.readdirAsync './template'
    .filter (file) -> file.endsWith '.hbs'
    .each (file) ->
      fs.readFileAsync "./template/#{file}"
        .then (t) ->
          template[file.replace('.hbs', '')] = handlebars.compile t.toString()
    .catch (e) -> ''
    .all()
    .then ->
      if not (template.default? and template.index?)
        throw new Error 'No default template provided'

buildBlogContext = (isHome = false) ->
    title: configuration.config.title
    description: configuration.config.description
    url: configuration.config.url
    isHome: isHome

renderTemplate = (fn, context) ->
  ret = fn context
  new Promise (resolve) ->
    async.done (values) ->
      Object.keys(values).forEach (id) ->
        ret = ret.replace id, values[id]
        ret = ret.replace handlebars.Utils.escapeExpression(id), handlebars.Utils.escapeExpression(values[id])
      # TODO: Allow plugins to modify rednering results
      resolve ret


renderDefault = (content, isHome = false) ->
  context =
    blog: buildBlogContext(isHome)
    arguments: configuration.config.template_arguments
    content: content

  renderTemplate template.default, context

renderIndex = (posts, page = 0) ->
  context =
    blog: buildBlogContext(page is 0)
    arguments: configuration.config.template_arguments
    firstPage: page is 0
    lastPage: false
    nextPage: "/page/#{page + 1}"
    prevPage: if page == 1 then "/" else "/page/#{page - 1}"
  totalPages = Math.floor(posts.length / configuration.config.posts_per_page) + 1
  return null if page >= totalPages
  start = page * configuration.config.posts_per_page
  end = (page + 1) * configuration.config.posts_per_page - 1
  if end >= posts.length
    end = posts.length - 1
    context.lastPage = true
  context.posts = posts[start..end]
  renderTemplate template.index, context
    .then (index) -> renderDefault index, (page is 0)

module.exports =
  reload: reload
  renderIndex: renderIndex