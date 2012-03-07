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
    PATH_ABOUT = "#{SEPARATOR}about"
    PATH_CONTACTS = "#{SEPARATOR}contacts"

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
      @title = CONFIGURATION[:locales][@locale][:head][:text]
      @path = CHAR_EMPTY
      haml :index
    end

    get PATH_LOCALE + PATH_ABOUT do
      def_lang
      @title = CONFIGURATION[:locales][@locale][:menu][3]
      @path = PATH_ABOUT
      haml :index
    end

    get PATH_LOCALE + PATH_CONTACTS do
      def_lang
      @title = CONFIGURATION[:locales][@locale][:menu][4]
      @path = PATH_CONTACTS
      haml :index
    end

    not_found do
      def_lang
      redirect SEPARATOR + @locale
    end

    error do
      def_lang
      redirect SEPARATOR + @locale
    end

    private

    def def_lang
      @locale = ((params[:locale])?(params[:locale]):(request.path_info.split(SEPARATOR)[1])).to_s
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
