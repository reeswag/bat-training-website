require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'

module TrainingHelpers
    def references options
        if options[:url] != nil
            '<p class="references"' + '>' + options[:text] + ' Available at: ' '<a href="' + options[:url] + '">' + options[:url] + '</a></p>'
        else
            '<p class="references"' + '>' + options[:text]
        end
    end
end

class BatTrainingResources < Sinatra::Base
    enable :method_override # allows the _method overrides to work.
    register Sinatra::Flash

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
        (request.path==path || request.path==path+'/') ? "nav-item active" : "nav-item"
    end

    def current_dropdown?(path='/')
        (request.path==path || request.path==path+'/') ? "dropdown-item active" : "dropdown-item"
    end

    def set_title
        @title ||= "Bat Training Resource"
    end

    get '/*' do
        viewname = (params[:splat].first)  # eg "some/path/here" 
        @title = viewname.gsub("-"," ").split.map(&:capitalize)*' '#this converts the url into a page title with title case.
        #begin
            slim:"btr/#{viewname}", :layout => :"btr/layout-btr"
        #rescue 
           #redirect(MAIN_URL)
        #end
    end
end