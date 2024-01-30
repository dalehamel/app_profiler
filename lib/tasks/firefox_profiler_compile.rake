# frozen_string_literal: true

require 'rubygems/package'
require 'zlib'
require 'fileutils'

require "app_profiler"
require "app_profiler/yarn/command"
require "app_profiler/yarn/with_firefox_profiler"

class CompileShim
  include AppProfiler::Yarn::WithFirefoxProfile
end

namespace :firefox_profiler do
  desc "Compile firefox profiler"
  task :compile do
    AppProfiler.root = Pathname.getwd
    CompileShim.new.setup_yarn
  end
  desc "Package firefox profiler"
  task package: :compile do
    puts "PACKAGING"
  end
end

source_dir = '/path/to/source/directory'
tar_gz_filename = '/path/to/output/file.tar.gz'

File.open(tar_gz_filename, 'wb') do |tar_gz_file|
  Zlib::GzipWriter.wrap(tar_gz_file) do |gzip_file|
    Gem::Package::TarWriter.new(gzip_file) do |tar|
      Dir[File.join(source_dir, '**/*')].each do |file|
        mode = File.stat(file).mode
        relative_path = file.sub /^#{Regexp::escape source_dir}\//, ''

        if File.directory?(file)
          tar.mkdir(relative_path, mode)
        else
          tar.add_file_simple(relative_path, mode, File.size(file)) do |tar_file|
            IO.copy_stream(File.open(file, 'rb'), tar_file)
          end
        end
      end
    end
  end
end
