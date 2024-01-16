# frozen_string_literal: true

require "app_profiler/viewer/remote_viewer/base_middleware"

module AppProfiler
  module Viewer
    class RemoteViewer < BaseViewer
      class FirefoxBaseMiddleware < RemoteBaseMiddleware
        def call(env)
          request = Rack::Request.new(env)
          @app.call(env) if request.path_info.end_with?(".stackprof.json")
          # Firefox profiler *really* doesn't like for /from-url/ to be at any other mount point
          # so with this enabled, we take over both /app_profiler and /from-url in the app in development.
          return from(env, Regexp.last_match(1))   if request.path_info =~ %r(\A/from-url(.*)\z)
          return viewer(env, Regexp.last_match(1)) if request.path_info =~ %r(\A/app_profiler/firefox/viewer/(.*)\z)
          return show(env, Regexp.last_match(1))   if request.path_info =~ %r(\A/app_profiler/firefox/(.*)\z)

          super
        end
      end

      private_constant(:FirefoxBaseMiddleware)
    end
  end
end
