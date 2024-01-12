# frozen_string_literal: true

require "app_profiler/viewer/remote_viewer/base_middleware"

module AppProfiler
  module Viewer
    class RemoteViewer < BaseViewer
      class SpeedscopeBaseMiddleware < RemoteBaseMiddleware
      end
    end
  end
end
