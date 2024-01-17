# frozen_string_literal: true

require "test_helper"

module AppProfiler
  module Viewer
    class SpeedscopeViewerTest < TestCase
      test ".view initializes and calls #view" do
        SpeedscopeViewer.any_instance.expects(:view)

        profile = StackprofProfile.new(stackprof_profile)
        SpeedscopeViewer.view(profile)
      end

      test "#view logs middleware URL" do
        profile = StackprofProfile.new(stackprof_profile)

        viewer = SpeedscopeViewer.new(profile)
        id = SpeedscopeViewer::Middleware.id(profile.file)

        AppProfiler.logger.expects(:info).with(
          "[Profiler] Profile available at /app_profiler/#{id}\n"
        )

        viewer.view
      end

      test "#view with response redirects to URL" do
        response = [200, {}, ["OK"]]
        profile = StackprofProfile.new(stackprof_profile)

        viewer = SpeedscopeViewer.new(profile)
        id = SpeedscopeViewer::Middleware.id(profile.file)

        viewer.view(response: response)

        assert_equal(303, response[0])
        assert_equal("/app_profiler/speedscope/viewer/#{id}", response[1]["Location"])
      end
    end
  end
end
