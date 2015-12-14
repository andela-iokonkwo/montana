require "rack"
require "slim"

module Montana
  class Base
    attr_reader :req
    def initialize
      @endpoints = {}
    end

    %w(get post patch put destroy).each do |method_name|
      define_method(method_name) do |path, &block|
        route(method_name.to_sym, path, &block)
      end
    end

    def call(env)
      @req = Rack::Request.new(env)
      path = @req.path_info
      verb = @req.request_method.downcase.to_sym
      block_to_execute = @endpoints.fetch(verb, {}).fetch(path, nil)

      if block_to_execute
        # block_to_execute.call(req = @req)
        response = instance_eval(&block_to_execute)
        if response.class == String
          [200, {"Content-Type" => "text/html"}, [response]]
        else
          response
        end
      else
        [404, {}, ["This endpoint do not exist"]]
      end
    end

    def render(page, locals)
      filename = File.join(File.dirname(__FILE__), "views", "#{page}")
      scope = Object.new
      locals.each do |index, item|
        scope.instance_variable_set("@#{index}", item)
      end
      Slim::Template.new("views/#{page}.slim").render(scope)
    end

    def params
      @req.params
    end

    private
      def route(verb, path, &block)
        @endpoints[verb] ||= {}
        @endpoints[verb][path] = block
      end
  end

  Application = Base.new

  module Delegator

    def self.delegate(*methods, to:)
      Array(methods).each do |method_name|
        define_method(method_name) do |*args, &block|
          to.send(method_name, *args, &block)
        end
      end
    end

    delegate :get, :post, :patch, :put, :destroy, :render, to: Application
  end
end

include Montana::Delegator
