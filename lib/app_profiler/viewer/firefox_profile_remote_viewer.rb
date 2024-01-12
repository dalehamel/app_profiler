# frozen_string_literal: true

require "app_profiler/viewer/firefox_remote_viewer/base_middleware"
require "app_profiler/viewer/firefox_remote_viewer/firefox_middleware"

module AppProfiler
  module Viewer
    class FirefoxProfileRemoteViewer < BaseViewer
      class << self
        def view(profile, params = {})
          new(profile).view(**params)
        end
      end

      def initialize(profile)
        super()
        @profile = profile
      end

      def view(response: nil, autoredirect: nil, async: false)
        id = AppProfiler::Viewer::RemoteViewer::FirefoxMiddleware.id(@profile.file)

        if response && response[0].to_i < 500
          response[1]["Location"] = "/app_profiler/viewer/#{id}"
          response[0] = 303
        else
          AppProfiler.logger.info("[Profiler] Profile available at /app_profiler/#{id}\n")
        end
      end
    end
  end
end
