require.cache['plugin'] = module # Enable this to be directly required
Module = require 'module'
realResolve = Module._resolveFilename
Module._resolveFilename = (request, parent) ->
  if request is 'plugin'
    return 'plugin'
  realResolve request, parent

{Promise} = require '../utils/dependencies'

class Plugin
  constructor: ->
    registerPlugin @

plugins = []
registerPlugin = (plugin) ->
  plugins.push plugin
loadPlugins = (config) ->
  return if not config.plugins?
  config.plugins.forEach (it) ->
    if it.startsWith 'npm://'
      require it.replace 'npm://', ''
    else
      require "#{process.cwd()}/#{it}"
# To enable chaining, please return [false, function] in the plugin method
# Otherwise chaining will be disabled.
# When allowChaining is true, the plugin method will receive the original
# arguments as its own arguments. To get the result from the last plugin,
# please use the arguments passed to  [function] returned by the method.
# See example/plugins/ for details.
callPluginMethod = (name, args, allowChaining = false) ->
  lastPromise = null
  for p in plugins
    if p[name]? and (typeof p[name] is 'function')
      [ok, promise] = p[name].apply @, args
      return promise if ok
      if promise? and allowChaining
        throw new Error 'Not returning a function for chaining plugins' if typeof promise isnt 'function'
        if lastPromise?
          lastPromise = lastPromise.then promise
        else
          lastPromise = Promise.try =>
            promise.apply @, args
  if (not allowChaining) or (not lastPromise?)
    [ok, promise] = defaultPlugin[name].apply @, args
    return promise if ok
    throw new Error "No plugin for #{name} found"
  else
    return lastPromise
loadPost = (name) ->
  callPluginMethod 'loadPost', arguments
parsePost = (content) ->
  callPluginMethod 'parsePost', arguments
transformExpressApp = (app) ->
  callPluginMethod 'transformExpressApp', arguments, true # Allow chaining plugins
transformRenderResult = (content) ->
  callPluginMethod 'transformRenderResult', arguments, true # Allow chaining plugins

module.exports =
  registerPlugin: registerPlugin
  loadPlugins: loadPlugins
  callPluginMethod: callPluginMethod
  loadPost: loadPost
  parsePost: parsePost
  transformExpressApp: transformExpressApp
  transformRenderResult: transformRenderResult
  Plugin: Plugin
  dependencies: require '../utils/dependencies'
  configuration: require '../utils/configuration'

defaultPlugin = require './default'