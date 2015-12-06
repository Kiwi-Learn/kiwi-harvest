require 'sinatra/base'
require 'sinatra/flash'

require 'hirb'
require 'slim'
require 'chartkick'
require 'groupdate'

require 'httparty'
require 'date'

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
    set :api_server, 'https://kiwi-learn.herokuapp.com'
  end

  configure :production do
    set :api_server, 'https://kiwi-learn.herokuapp.com'
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
    # dateTmp = []
    # @courselist.each do |course|
    #   unless course["date"][0..9]==='0000-00-00'
    #     dateTmp << Date.parse(course["date"][0..9].gsub('-','/')) # handle time encoding
    #   end
    # end
    # @dates = Hash[ dateTmp.group_by_month(format: "%b %Y") { |u| u }.map { |k, v| [k, v.size]} ]
    # logger.info @dates
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

  app_get_date_stat =lambda do
    response = HTTParty.get("#{settings.api_server}/#{settings.api_ver}/courselist")
    logger.info "#{settings.api_server}/#{settings.api_ver}/courselist"
    @courselist = JSON.parse(response.body)
    dateTmp = []
    @courselist.each do |course|
      unless course["date"][0..9]==='0000-00-00'
        dateTmp << Date.parse(course["date"][0..9].gsub('-','/')) # handle time encoding
      end
    end
    @dates = Hash[ dateTmp.group_by_month(format: "%b %Y") { |u| u }.map { |k, v| [k, v.size]} ]
    logger.info @dates

    slim :course_date_stat
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/courses', &app_get_courses
  get '/courses/:id', &app_get_courses_info
  get '/search' , &app_get_search
  get '/date', &app_get_date_stat
  post '/search' ,&app_post_search

end
