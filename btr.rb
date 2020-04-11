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

    helpers TrainingHelpers

    before do
        last_modified Website.settings.start_time
        etag Website.settings.start_time.to_s
        cache_control :public, :must_revalidate  # makes the client confirm if there have been any changes to each web page since the start of the application before making a request. 
        set_title # this assigns the title before loading each view
    end

    def css(*stylesheets) # the * signifies that this function can take any number of arguments.
        stylesheets.map do |stylesheet|
            "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel =\"stylesheet\" />" # this generates
        end.join # the .join here translates multiple inputs into a combined string file which can be injected into the .slim file. Without it we'd end up with an array of text files.    
    end

    def current?(path='/')
        (request.path==path || request.path==path+'/') ? "current" : nil
    end

    def set_title
        @title ||= "Bat Training Resource"
    end

    get '/*' do
        viewname = (params[:splat].first)  # eg "some/path/here"
        p viewname
        slim:"btr/#{viewname}"
    end
end