require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'
require './sinatra/auth'

module TrainingHelpers
end

class BatTrainingResources < Sinatra::Base
    enable :method_override # allows the _method overrides to work.
    register Sinatra::Flash
    register Sinatra::Auth
end