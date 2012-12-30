require 'rubygems'
require 'sinatra/base'
require 'sprockets'
require 'sprockets/engines'
require 'barber'
require 'active_support/ordered_options'
require 'sprockets-sass'
require 'haml'
require 'sass'
require 'compass'
require 'yui/compressor'
require 'uglifier'
require 'execjs'
require 'base64'
require 'rack/utils'
require 'html_compressor'
require 'vegas'
require 'zurb-foundation'

Rack::Mime::MIME_TYPES['.template'] = Rack::Mime.mime_type('.html')

module AssetHelpers
    def asset_path(source, options = {})
      "public/images/#{source}"
    end
    def image_path(source, options = {})
      "public/images/#{source}"
    end
    def asset_data_uri(source, options = {})
      unless Assets.instance.find_asset(source).nil?
        asset  = Assets.instance.find_asset(source)
        base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
        "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
      end
    end
  end

class Assets < Sprockets::Environment

  def initialize(assets_path)
    super
    context_class.instance_eval do
      include AssetHelpers
    end
  end
end

class SHTTilt < Tilt::Template
  def self.default_mime_type
    'application/javascript'
  end

  def prepare; end

  def evaluate(scope, locals, &block)
    target = template_target(scope)
    raw = handlebars?(scope)

    if raw
      template = data
    else
      template = mustache_to_handlebars(scope, data)
    end

    if configuration.precompile
      if raw
        template = precompile_handlebars(template)
      else
        template = precompile_ember_handlebars(template)
      end
    else
      if raw
        template = compile_handlebars(data)
      else
        template = compile_ember_handlebars(template)
      end
    end

    "#{target} = #{template}\n"
  end

  private

  def handlebars?(scope)
    scope.pathname.to_s =~ /\.raw\.(handlebars|hjs|hbs)/
  end

  def template_target(scope)
    "Ember.TEMPLATES[#{template_path(scope.logical_path).inspect}]"
  end

  def compile_handlebars(string)
    "Handlebars.compile(#{indent(string).inspect});"
  end

  def precompile_handlebars(string)
    Barber::FilePrecompiler.call(string)
  end

  def compile_ember_handlebars(string)
    "Ember.Handlebars.compile(#{indent(string).inspect});"
  end

  def precompile_ember_handlebars(string)
    Barber::Ember::FilePrecompiler.call(string)
  end

  def mustache_to_handlebars(scope, template)
    if scope.pathname.to_s =~ /\.mustache\.(handlebars|hjs|hbs)/
      template.gsub(/\{\{(\w[^\}\}]+)\}\}/){ |x| "{{unbound #{$1}}}" }
    else
      template
    end
  end

  def template_path(path)
    root = configuration.templates_root

    if root.kind_of? Array
      root.each do |root|
        path.gsub!(/^#{Regexp.quote(root)}\//, '')
      end
    else
      unless root.empty?
        path.gsub!(/^#{Regexp.quote(root)}\/?/, '')
      end
    end

    path = path.split('/')

    path.join(configuration.templates_path_separator)
  end

  def configuration
    handlebars = ::ActiveSupport::OrderedOptions.new
    handlebars.precompile = true
    handlebars.templates_root = "templates"
    handlebars.templates_path_separator = '/'
    handlebars
  end

  def indent(string)
    string.gsub(/$(.)/m, "\\1  ").strip
  end
  
  def path_to_key(scope)
    path = scope.logical_path.to_s.gsub(/^templates\/(.*)$/i, "\\1").split('/')
    path.last.gsub!(/^_/, '')
    path.join('/')
  end
end

class MoscowYammerServer < Sinatra::Application
  
  set :root, File.dirname(__FILE__)
  set :public_folder, File.expand_path(File.join(root, '..', 'public'))
 
  set :sprockets, (Assets.new(root) { |env| env.logger = Logger.new(STDOUT) })
  set :assets_prefix, 'assets'
  set :assets_path, File.join(root, '..', 'attachments', assets_prefix)
  set :compass_gem_root, Gem.loaded_specs['compass'].full_gem_path
  set :foundation_gem_root, Gem.loaded_specs['zurb-foundation'].full_gem_path
  
  configure do
    sprockets.register_engine ".handlebars", SHTTilt
    
    sprockets.append_path File.join(root, '..', 'assets', 'stylesheets')
    sprockets.append_path File.join(compass_gem_root, 'frameworks', 'compass', 'stylesheets')
    sprockets.append_path File.join(compass_gem_root, 'frameworks', 'blueprint', 'stylesheets')
    sprockets.append_path File.join(foundation_gem_root, 'scss')
    sprockets.append_path File.join(foundation_gem_root, 'vendor', 'assets', 'javascripts')
    sprockets.append_path File.join(root, '..', 'assets', 'javascripts')
    if ENV['RELEASE']
      sprockets.css_compressor = YUI::CssCompressor.new
      sprockets.js_compressor  = Uglifier.new(mangle: true)
    end
  end
  
  helpers do
    include AssetHelpers
  end

  get /\/(attachments|public|vendor)\/(.*)/ do
    filename = File.join(params['captures'][0], params['captures'][1])
    content_type File.extname(filename)
    read_relative_file '..', filename
  end
  
  get '/' do
    content_type 'text/html'
    erb :"index.html"
  end
  
  get '/release' do
    content_type 'text/html'
    read_relative_file '..', 'index.html'
  end

  def read_relative_file(*args)
    File.read(File.join(File.expand_path(File.dirname(__FILE__)), *args))
  end

end