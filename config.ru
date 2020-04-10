require 'sinatra/base'

require './main' 
require './btr'

map('/btr') { run BatTrainingResources }
map('/') { run Website }