# frozen_string_literal: true

module AppProfiler
  module Yarn
    module WithFirefoxProfile
      include Command

      def setup_yarn
        super
        return if firefox_profiler_added?

        fetch_firefox_profiler
        yarn("--cwd", "node_modules/firefox-profiler")

        patch_firefox_profiler
        yarn("--cwd", "node_modules/firefox-profiler", "build-prod")
        patch_file("node_modules/firefox-profiler/dist/index.html", 'href="locales/en-US/app.ftl"',
          'href="/app_profiler/firefox/viewer/locales/en-US/app.ftl"')
      end

      private

      def firefox_profiler_added?
        AppProfiler.root.join("node_modules/firefox-profiler").exist?
      end

      def fetch_firefox_profiler
        raise ArgumentError unless AppProfiler.gecko_viewer_package.start_with?("https://github.com")

        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            system("git", "clone", AppProfiler.gecko_viewer_package.to_s, "firefox-profiler")
            package_contents = File.read("firefox-profiler/package.json")
            package_json = JSON.parse(package_contents)
            package_json["name"] ||= "firefox-profiler"
            package_json["version"] ||= "0.0.1"
            File.write("firefox-profiler/package.json", package_json.to_json)
          end
          yarn("add", "#{dir}/firefox-profiler")
        end
      end

      def patch_firefox_profiler
        # Patch the publicPath so that the app can be "mounted" at the right location
        patch_file("node_modules/firefox-profiler/webpack.config.js", "publicPath: '/'",
          "publicPath: '/app_profiler/firefox/viewer/'")
        patch_file("node_modules/firefox-profiler/src/app-logic/l10n.js", "fetch(`/locales/",
          "fetch(`/app_profiler/firefox/viewer/locales/")
      end

      def patch_file(file, find, replace)
        contents = File.read(file)
        new_contents = contents.gsub(find, replace)
        File.write(file, new_contents)
      end
    end
  end
end
