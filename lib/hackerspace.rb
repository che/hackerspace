# encoding: utf-8

require 'yaml'


module HACKERSPACE

  SEPARATOR = '/'

  CHAR_EMPTY = ''
  CHAR_DOG = '@'
  CHAR_DOT = '.'

  YAML_FILE_EXTENSION = '.yml'
  RUBY_FILE_EXTENSION = '.rb'

  REG_YAML_FILE = /[.][Yy][Mm][Ll]$/
  REG_RUBY_FILE = /[.][Rr][Bb]$/
  REG_SEPARATOR = /[\/]$/
  REG_SPACES = /[\s\t]/

  LOCALES_DIR = 'locales' + SEPARATOR
  ROOT_DIR = File.dirname(File.dirname(File.expand_path(__FILE__)))
  CONFIG_DIR = ROOT_DIR + SEPARATOR + 'config' + SEPARATOR
  PUBLIC_DIR = ROOT_DIR + SEPARATOR + 'public'
  VIEWS_DIR = ROOT_DIR + SEPARATOR + 'views'

  NAME = File.basename(__FILE__, RUBY_FILE_EXTENSION)

  ENCODING_DEFAULT = 'utf-8'
  LOCALE_DEFAULT = 'en'

  CONFIGURATION = {}

  def self.init
    for i in YAML.load_file(CONFIG_DIR + NAME + YAML_FILE_EXTENSION)[NAME] do
      if i[1].kind_of?(Hash)
        for ii in i[1].keys do
          i[1][ii.to_sym] = i[1].delete(ii)
        end
      end
      CONFIGURATION[i[0].to_sym] = i[1]
    end
    CONFIGURATION[:phone] = {:title => CONFIGURATION[:phone], :number => CONFIGURATION[:phone].gsub(REG_SPACES, CHAR_EMPTY)} if CONFIGURATION[:phone]
    CONFIGURATION[:domain] = NAME + CHAR_DOT + CONFIGURATION[:domain] if CONFIGURATION[:domain]
    CONFIGURATION[:email] = CONFIGURATION[:email] + CHAR_DOG + CONFIGURATION[:domain] if CONFIGURATION[:email] && !CONFIGURATION[:email][CHAR_DOG]
    CONFIGURATION[:sites] = CONFIGURATION[:sites].split(REG_SPACES) if CONFIGURATION[:sites]
    CONFIGURATION[:html] = CONFIGURATION[:html].to_sym if CONFIGURATION[:html]
    CONFIGURATION[:foundation_year] = Time.now.year unless CONFIGURATION[:foundation_year]
    if CONFIGURATION[:locale]
      CONFIGURATION[:locale][:list] = CONFIGURATION[:locale][:list].split(REG_SPACES) if CONFIGURATION[:locale][:list]
      CONFIGURATION[:locale][:default] = LOCALE_DEFAULT unless CONFIGURATION[:locale][:default]
    end
    CONFIGURATION[:locales] = {}
    @path = CONFIG_DIR + LOCALES_DIR
    for i in Dir.entries(@path) do
      @file = @path + i
      if @file =~ REG_YAML_FILE && File.exists?(@file) && File.file?(@file)
        CONFIGURATION[:locales].merge!(YAML.load_file(@file))
      end
    end
    CONFIGURATION[:locale][:list].replace(CONFIGURATION[:locale][:list] & CONFIGURATION[:locales].keys)
    for i in CONFIGURATION[:locale][:list] do
      for l in CONFIGURATION[:locales].delete(i) do
        CONFIGURATION[:locales][i] = {} unless CONFIGURATION[:locales][i]
        if l[1].kind_of?(Hash)
          for k in l[1].keys do
            l[1][k.to_sym] = l[1].delete(k) if k.kind_of?(String)
          end
        end
        CONFIGURATION[:locales][i][l[0].to_sym] = l[1]
      end
    end
    if CONFIGURATION[:locale][:list].include?(CONFIGURATION[:locale][:default])
      @path = File.dirname(File.expand_path(__FILE__)) + SEPARATOR + NAME
      for i in Dir.entries(@path).sort[2..-1].reverse do
        @file = @path + SEPARATOR + i
        require @file if @file =~ REG_RUBY_FILE && File.exists?(@file) && File.file?(@file)
      end
    end
    for i in instance_variables do
      remove_instance_variable(i)
    end
    CONFIGURATION.freeze
  end

end
