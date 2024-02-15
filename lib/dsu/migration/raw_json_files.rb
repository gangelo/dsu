# frozen_string_literal: true

require 'fileutils'
require 'pathname'

require_relative 'raw_json_file'

module Dsu
  module Migration
    class RawJsonFiles
      attr_reader :folder

      def initialize(folder)
        @folder = folder
      end

      def each_file(regex: //)
        return unless folder_exist?

        Pathname.new(folder).children.each do |child|
          next unless child.file? && child.to_s.match?(regex)

          yield RawJsonFile.new(child)
        end
      end

      def folder_exist?
        self.class.folder_exist?(folder: folder)
      end

      class << self
        def folder_exist?(folder:)
          Dir.exist?(folder)
        end
      end

      private

      attr_writer :folder

      def safe_cp_r(source, destination)
        Pathname.new(source).find do |source_path|
          next if source_path.directory?

          relative_path = source_path.relative_path_from(Pathname.new(source))
          target_path = Pathname.new(destination).join(relative_path)

          next if target_path.exist?

          FileUtils.mkdir_p(target_path.dirname)
          FileUtils.cp(source_path, target_path)
        end
      end
    end
  end
end
