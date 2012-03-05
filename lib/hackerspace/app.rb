# encoding: utf-8

require 'sinatra'
require 'haml'


module HACKERSPACE
  class Site < Sinatra::Base
    set :haml, :format => CONFIGURATION[:html]
    set :public_folder, PUBLIC_DIR
    set :views, VIEWS_DIR
    set :root, ROOT_DIR
    enable :static_cache_control
    disable :show_exceptions
    disable :sessions

    LOCALE_REQUEST_KEY = 'HTTP_ACCEPT_LANGUAGE'
    PATH_LOCALE = "#{SEPARATOR}:locale"
    PATH_IRC = "#{SEPARATOR}irc"
    PATH_ABOUT = "#{SEPARATOR}about"

    REG_LOCALE_SEPARATOR1 = /[;]/
    REG_LOCALE_SEPARATOR2 = /[,]/

    before do
      request.path_info = request.path_info.chop if request.path_info =~ REG_SEPARATOR && request.path_info != SEPARATOR
    end

    get "#{SEPARATOR}*.css" do
      content_type "text#{SEPARATOR}css"
      pass
    end

    get SEPARATOR do
      def_lang
      redirect SEPARATOR + @locale
    end

    get PATH_LOCALE do
      def_lang
      @head = CONFIGURATION[:locales][@locale][:head][:text]
      haml :index
    end

    get PATH_LOCALE + PATH_IRC do
      def_lang
      @head = CONFIGURATION[:locales][@locale][:menu][3]
      haml :index
    end

    get PATH_LOCALE + PATH_ABOUT do
      def_lang
      @head = CONFIGURATION[:locales][@locale][:menu][4]
      haml :index
    end

    not_found do
      redirect SEPARATOR
    end

    error do
      redirect SEPARATOR
    end

    private

    def def_lang
      @locale = params[:locale].to_s
      if @locale.empty?
        begin
          @locale = request.env[LOCALE_REQUEST_KEY].split(REG_LOCALE_SEPARATOR1)[0].split(REG_LOCALE_SEPARATOR2)[-1]
        rescue
          @locale = CONFIGURATION[:locale][:default]
        end
      end
      @locale = CONFIGURATION[:locale][:default] unless CONFIGURATION[:locale][:list].include?(@locale)
    end

  end
end
