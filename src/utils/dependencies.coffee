# This file contains the common dependencies for all modules in this project
# Allow directly requiring .coffee files for extensions
require 'coffee-script/register'

# The Promise implemetation
Promise = require 'bluebird'

module.exports = 
  Promise: Promise
  fs: Promise.promisifyAll require 'fs'