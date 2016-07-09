{Promise, fs} = require './utils/dependencies'
{callPluginMethod, loadPost, parsePost, transformExpressApp} = require './plugin/plugin'
express = require 'express'
{renderIndex} = require './template'
configuration = require './utils/configuration'
configuration.on 'change', (config) ->
  checkConfig config

posts = {}
postsArr = []

start = ->
  return if not checkConfig configuration.config
  app = express()
  app.use '/assets', express.static 'template/assets'
  app.get '/', (req, res) ->
    renderIndex postsArr, 0
      .then (index) -> res.send index
  app.get '/page/:id(\\d+)', (req, res) ->
    promise = renderIndex postsArr, parseInt req.params.id
    if not promise?
      res.sendStatus 404
    else
      promise.then (page) -> res.send page
  app.get '/*', (req, res) ->
    postName = req.params[0]
    if posts[postName]?
      res.send posts[postName].content # TODO: render the post
    else
      res.sendStatus 404
    res.end()

  transformExpressApp app

  app.listen configuration.config.port, '127.0.0.1', ->
    console.log "Listening on 127.0.0.1:#{configuration.config.port}"

checkConfig = (config) ->
  if not (config.title? and config.url? and config.description?)
    console.error 'Please provide at least `title` `url` and `description`'
    return false
  if not config.posts? or config.posts.length is 0
    console.error 'No posts found'
    return false
  if not config.port?
    config.port = "2333"
  if isNaN parseInt config.port
    console.error "Invalid port #{config.port}"
    return false
  if not config.posts_per_page?
    config.posts_per_page = 5
  if isNaN parseInt config.posts_per_page
    console.error "Invalid number #{config.posts_per_page}"
    return false
  reloadPosts()
  true

reloadPosts = ->
  newPosts = {}
  Promise.map configuration.config.posts, (item) ->
    loadPost item
  .map parsePost
  .map (data) ->
    callPluginMethod "parseContent#{data.parser}", [data.content]
      .then (content) ->
        data.content = content
        return data
  .each (item) ->
    newPosts[item.url] = item
  .all()
  .then ->
    posts = newPosts
    postsArr = (post for _, post of posts)
  .catch (e) ->
    console.error e
    process.exit 1

module.exports =
  start: start