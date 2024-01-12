# frozen_string_literal: true

require "app_profiler/yarn/command"
require "app_profiler/yarn/with_firefox_profiler"

module AppProfiler
  module Viewer
    class RemoteViewer < BaseViewer
      class FirefoxMiddleware < FirefoxBaseMiddleware
        include Yarn::WithFirefoxProfile

        def initialize(app)
          super
          @firefox_profiler = Rack::File.new(
            File.join(AppProfiler.root, "node_modules/firefox-profiler/dist")
          )
        end

        protected

        attr_reader(:firefox_profiler)

        def viewer(env, path)
          setup_yarn unless yarn_setup

          if path.ends_with?(".json")
            proto = env['rack.url_scheme']
            host = env['HTTP_HOST']
            source = "#{proto}://#{host}/app_profiler/#{path.gsub("/viewer", "")}"

            target = "/from-url/#{CGI.escape(source)}"
      
            ['302', {'Location' => target}, []]
          else
            env[Rack::PATH_INFO] = path.delete_prefix("/app_profiler")
            firefox_profiler.call(env)
          end
        end

        def from(env, path)
          setup_yarn unless yarn_setup
          index = File.read(File.join(AppProfiler.root, "node_modules/firefox-profiler/dist/index.html"))
          ['200', {"Content-Type" => "text/html"}, [index]]
        end

        def show(_env, name)
          profile = profile_files.find do |file|
            id(file) == name
          end || raise(ArgumentError)

          ['200', {'Content-Type' => 'application/json'}, [profile.read]]
        end
      end
    end
  end
end
