# frozen_string_literal: true

require 'fileutils'
require 'json'

module Dsu
  module Crud
    class JsonFile
      attr_reader :file_path

      def initialize(file_path:, options: {})
        raise ArgumentError, 'file_path is nil' if file_path.nil?
        raise ArgumentError, "file_path is the wrong object type: \"#{file_path}\"" unless file_path.is_a?(String)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

        @file_path = file_path
        @options = options || {}
      end

      def exist?
        self.class.exist?(file_path: file_path)
      end

      def read
        self.class.read(file_path: file_path)
      end

      def read!
        self.class.read!(file_path: file_path)
      end

      def write!(file_hash:)
        self.class.write!(file_hash: file_hash, file_path: file_path)
      end

      def write(file_hash:)
        self.class.write(file_hash: file_hash, file_path: file_path)
      end

      def delete!
        self.class.delete!(file_path: file_path)
      end

      def delete
        self.class.delete(file_path: file_path)
      end

      class << self
        def exist?(file_path:)
          File.exist?(file_path)
        end

        def read!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless exist?(file_path: file_path)

          read(file_path: file_path)
        end

        def read(file_path:)
          file_hash = {}
          file_hash = JSON.parse(File.read(file_path), symbolize_names: true) if exist?(file_path: file_path)
          yield file_hash if block_given?

          file_hash
        end

        def write!(file_hash:, file_path:)
          raise file_already_exists_message(file_path: file_path) if exist?(file_path: file_path)

          write(file_hash: file_hash, file_path: file_path)
        end

        def write(file_hash:, file_path:)
          raise ArgumentError, 'file_hash is nil' if file_hash.nil?
          raise ArgumentError, "file_hash is the wrong object type:\"#{file_hash}\"" unless file_hash.is_a?(Hash)

          File.write(file_path, JSON.pretty_generate(file_hash))
        end

        def delete!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless delete(file_path: file_path)
        end

        def delete(file_path:)
          return false unless exist?(file_path: file_path)

          File.delete(file_path)

          true
        end

        def file_does_not_exist_message(file_path:)
          "File \"#{file_path}\" does not exist"
        end

        def file_already_exists_message(file_path:)
          "File \"#{file_path}\" already exists"
        end
      end

      private

      attr_reader :options
    end
  end
end
