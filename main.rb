require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'
require 'v8'
require 'coffee-script'
require './asset-handler'

class Website < Sinatra::Base
    use AssetHandler
    register Sinatra::Flash 

    configure do
        enable :sessions
    end

    configure :development do
        set :start_time => Time.now 
        
        set :email_options => {
            :from => "noreply@bat-training-website.herokuapp.com",
            :to => 'reeswag@gmail.com',
            :via => 'smtp',
            :via_options => {
                :address => 'smtp.mailgun.org',
                :port => '587',
                :enable_starttls_auto => true,
                :authentication => :plain,
                :user_name => "fakeusername",
                :password => "fakepassword"
            }
        }
    end

    configure :production do
        set :start_time => Time.now

        set :email_options => {      
            :from => 'noreply@bat-training-website.herokuapp.com',
            :to => 'reeswag@gmail.com',
            :via => :smtp,
            :via_options => {
              :address => 'smtp.mailgun.org',
              :port => '587',
              :enable_starttls_auto => true,
              :domain => 'heroku.com',
              :user_name => ENV['MAILGUN_SMTP_LOGIN'],
              :password => ENV['MAILGUN_SMTP_PASSWORD'],
              :authentication => :plain
            }
        }
    end
    
    before do
        last_modified settings.start_time
        etag settings.start_time.to_s
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
        @title ||= "Bat Surveyor Resource"
    end

    def send_message
        Pony.options = settings.email_options
        Pony.mail(
            :subject => "<" + params[:email] + "> " + params[:name] + " has contacted you.",
            :body => params[:message],
            :via => :smtp
        )
    end 

    get '/' do
        slim :home
    end

    get '/contact' do
        @title = "Contact"
        slim :contact
    end

    get '/gallery' do
        @tile ='Gallery'
        slim :gallery
    end

    not_found do
        status 404
        slim :not_found
    end

    post '/contact' do
            flash.now[:notice] = "Thank you for your message. I'll be in touch soon." if send_message
            slim :contact
    end
end