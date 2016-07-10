require.cache['plugin'] = module # Enable this to be directly required
Module = require 'module'
realResolve = Module._resolveFilename
Module._resolveFilename = (request, parent) ->
  if request is 'plugin'
    return 'plugin'
  realResolve request, parent

class Plugin
  constructor: ->
    registerPlugin @

plugins = []
registerPlugin = (plugin) ->
  plugins.push plugin
callPluginMethod = (name, args) ->
  for p in plugins
    if p[name]? and (typeof p[name] is 'function')
      [ok, promise] = p[name].apply @, args
      return promise if ok
  [ok, promise] = defaultPlugin[name].apply @, args
  return promise if ok
  throw new Error "No plugin for #{name} found"
loadPost = (name) ->
  callPluginMethod 'loadPost', arguments
parsePost = (content) ->
  callPluginMethod 'parsePost', arguments
transformExpressApp = (app) ->
  callPluginMethod 'transformExpressApp', arguments
transformRenderResult = (content) ->
  callPluginMethod 'transformRenderResult', arguments

module.exports =
  registerPlugin: registerPlugin
  callPluginMethod: callPluginMethod
  loadPost: loadPost
  parsePost: parsePost
  transformExpressApp: transformExpressApp
  transformRenderResult: transformRenderResult
  Plugin: Plugin
  dependencies: require '../utils/dependencies'

defaultPlugin = require './default'