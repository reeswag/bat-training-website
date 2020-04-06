require 'sinatra/base'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'
require 'v8'
require 'coffee-script'
require './song'
require './sinatra/auth'
require './asset-handler'

class Website < Sinatra::Base
    use AssetHandler
    register Sinatra::Auth
    register Sinatra::Flash 

    configure do
        enable :sessions
        set :username, 'frank'
        set :password, 'sinatra'
    end

    configure :development do
        set :start_time => Time.now 
        
        Pony.options = {
            :via => 'smtp',
            :via_options => {
                :address => 'smtp.mailgun.org',
                :port => '587',
                :enable_starttls_auto => true,
                :authentication => :plain,
                :user_name => 'fakeemail.mailgun.org',
                :password => 'fakepassword'
            }
        }
    end

    configure :production do
        set :start_time => Time.now

        Pony.options = {
            :via => 'smtp',
            :via_options => {
                :address => 'smtp.sendgrid.net',
                :port => '587',
                :domain => 'heroku.com',
                :enable_starttls_auto => true,
                :authentication => :plain,
                :user_name => ENV['SENDGRID_USERNAME'],
                :password => ENV['SENDGRID_PASSWORD']
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
        (request.path==path || request.path==path+'/') ? "current" : nil
    end

    def set_title
        @title ||= "Bat Training Resource"
    end

    def send_message
        Pony.mail(
            :from => params[:name] + "<" + params[:email] + ">",
            :to => 'totagi1972@smlmail.com',
            :subject => params[:name] + " has contacted you",
            :body => params[:message],
            :via => :smtp
        )
    end 

    # get('/styles.css'){ scss :styles } # This employs the sass helper to tell Sinatra to process this request using Sass using the styles file located within the views directory. - moved to asset-handler.rb
    # get('/javascripts/application.js'){ coffee :application } # this employs the coffee helper method to tell Sinatra to process the request using CoffeeScript using the application file in the views directory. - moved to asset-handler.rb

    get '/' do
        slim :home
    end

    get '/about' do
        @title = "All About This Website"
        slim :about
    end

    get '/contact' do
        @title = "Contact Us"
        slim :contact
    end

    get '/set/:name' do
        session[:name] = params[:name]
    end

    get '/get/hello' do
        "Hello #{session[:name]}"
    end

    not_found do
        slim :not_found
    end

    post '/contact' do
        send_message
        flash[:notice]="Thank you for your message. We'll be in touch soon."
        redirect to('/')
    end
end