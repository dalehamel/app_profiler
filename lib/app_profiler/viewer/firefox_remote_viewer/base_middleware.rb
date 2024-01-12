# frozen_string_literal: true

require "app_profiler/viewer/remote_viewer/base_middleware"

module AppProfiler
  module Viewer
    class RemoteViewer < BaseViewer
      class FirefoxBaseMiddleware < RemoteBaseMiddleware

        def self.id(file)
          file.basename.to_s
        end

        def call(env)
          request = Rack::Request.new(env)

          # Firefox profiler *really* doesn't like for /from-url/ to be at any other mount point
          # so with this enabled, we take over both /app_profiler and /from-url in the app in development.
          return from(env, Regexp.last_match(1))   if request.path_info =~ %r(\A/from-url(.*)\z)
          super
        end

        protected

        def index(_env)
          render(
            (+"").tap do |content|
              content << "<h1>Profiles</h1>"
              profile_files.each do |file|
                content << <<~HTML
                  <p>
                    <a href="/app_profiler/viewer/#{id(file)}">
                      #{id(file)}
                    </a>
                  </p>
                HTML
              end
            end
          )
        end
      end

      private_constant(:FirefoxBaseMiddleware)
    end
  end
end
