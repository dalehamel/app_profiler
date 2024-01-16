# frozen_string_literal: true

require "app_profiler/viewer/remote_viewer/base_middleware"

module AppProfiler
  module Viewer
    class RemoteViewer < BaseViewer
      class SpeedscopeBaseMiddleware < RemoteBaseMiddleware
        def call(env)
          request = Rack::Request.new(env)
          @app.call(env) if request.path_info.end_with?(".gecko.json")
          return viewer(env, Regexp.last_match(1)) if request.path_info =~ %r(\A/app_profiler/speedscope/viewer/(.*)\z)
          return show(env, Regexp.last_match(1))   if request.path_info =~ %r(\A/app_profiler/speedscope/(.*)\z)

          super
        end
      end
    end
  end
end
