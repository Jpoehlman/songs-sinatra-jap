require 'sinatra'
require "sinatra/reloader" if development?
require 'slim'
require "sass"
require 'dm-core'
require 'dm-migrations'
require './song'
require 'sinatra/flash'
require "pony"

configure :development do
  DataMapper.setup(:default, "sqlite3://#{ Dir.pwd}/development.db")
end

configure :production do
  DataMapper.setup(:default, ENV[' DATABASE_URL'])
end

# Jon

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

configure :development do
  set :bind, '0.0.0.0'
  set :port, 3000
end

before do
  set_title
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end

  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Jon"
  end

  def send_message
    Pony.mail({
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'poehlman356@gmail.com',
      :subject => params[:name] + " has contacted you",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => {
        :address              => 'smpt.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'poehlman356',
        :password             => 'chona-356',
        :authentication       => :plain,
        :domain               => 'localhost.localdomain'
      }
      })
  end
end

get('/styles.css'){ scss :styles }

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    slim :login
  end
end

get '/logout' do
  session.clear
  redirect to('/login')
end

get '/'do
	@title = "Sinatra page"
	slim :home
end

get '/about'  do
	@title = "All About This Website"
	 slim :about
end

get '/contact'  do
	@title = "where to contact us"
	slim :contact
end

not_found do
	slim :not_found
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon."
  redirect to('/')
end