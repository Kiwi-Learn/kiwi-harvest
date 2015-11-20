require 'sinatra/base'
require 'sinatra/flash'

require 'hirb'
require 'slim'

require 'httparty'


class ApplicationController < Sinatra::Base
  helpers CourseHelpers, SearchHelpers, ApplicationHelpers
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    set :session_secret, 'something'
    set :api_ver, 'api/v1'
  end

  configure :development, :test do
    set :api_server, 'https://kiwi-learn.herokuapp.com/'
  end

  configure :production do
    set :api_server, 'https://kiwi-learn.herokuapp.com/'
  end

  configure :production, :development do
    enable :logging
  end

  # Web App Views Methods
  app_get_root = lambda do
    slim :home
  end

  app_get_courses = lambda do
    response = HTTParty.get("#{settings.api_server}/#{settings.api_ver}/courselist")
    logger.info "#{settings.api_server}/#{settings.api_ver}/courselist"
    @courselist = JSON.parse(response.body)
    slim :courses
  end

  app_get_courses_info = lambda do
    response = HTTParty.get("#{settings.api_server}/#{settings.api_ver}/info/#{params[:id]}.json")
    @single_course = JSON.parse(response.body)
    slim :course_info
  end

  app_get_search = lambda do
    slim :search
  end

  app_post_search =lambda do
    form = SearchForm.new(params)
    # logger.info form
    request_url = "#{settings.api_server}/#{settings.api_ver}/search"
    error_send(back, "Following fields are required: #{form.error_fields}") \
      unless form.valid?

    logger.info request_url
    results = CheckSearchFromAPI.new(request_url, form).call
    
    if (results.code != 200)
      flash[:notice] = 'Could not found course'
      redirect '/search'
      return nil
    end

    # course_id = results.parsed_response['course_id']
    redirect "/courses/#{results.course_id}"
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/courses', &app_get_courses
  get '/courses/:id', &app_get_courses_info
  get '/search' , &app_get_search
  post '/search' ,&app_post_search

end
