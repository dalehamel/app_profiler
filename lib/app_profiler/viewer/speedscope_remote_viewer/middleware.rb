# frozen_string_literal: true

require "app_profiler/yarn/command"
require "app_profiler/yarn/with_speedscope"
require "app_profiler/viewer/speedscope_remote_viewer/base_middleware"

module AppProfiler
  module Viewer
    class RemoteViewer < BaseViewer
      class SpeedscopeMiddleware < SpeedscopeBaseMiddleware
        include Yarn::WithSpeedscope

        def initialize(app)
          super
          @speedscope = Rack::File.new(
            File.join(AppProfiler.root, "node_modules/speedscope/dist/release")
          )
        end

        protected

        attr_reader(:speedscope)

        def viewer(env, path)
          setup_yarn unless yarn_setup

          if path.ends_with?(".stackprof.json")
            source = "/app_profiler/speedscope/#{path}"
            target = "/app_profiler/speedscope/viewer/index.html#profileURL=#{CGI.escape(source)}"

            ["302", { "Location" => target }, []]
          else
            env[Rack::PATH_INFO] = path.delete_prefix("/app_profiler/speedscope")
            speedscope.call(env)
          end
        end

        def show(_env, name)
          profile = profile_files.find do |file|
            id(file) == name
          end || raise(ArgumentError)

          ["200", { "Content-Type" => "application/json" }, [profile.read]]
        end
      end
    end
  end
end
