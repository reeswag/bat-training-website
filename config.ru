require 'sinatra/base'

require './main' 
require './btr'

MAIN_URL='/'
BTR_URL='/btr'

map(BTR_URL) { run BatTrainingResources }
map(MAIN_URL) { run Website }