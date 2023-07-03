# frozen_string_literal: true

require 'fileutils'
require 'json'

module Dsu
  module Crud
    class RawFile
      attr_reader :file_path
      attr_accessor :file_data

      def initialize(file_path:, file_data: nil, options: {})
        raise ArgumentError, 'file_path is nil' if file_path.nil?
        raise ArgumentError, "file_path is the wrong object type: \"#{file_path}\"" unless file_path.is_a?(String)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

        @file_path = file_path
        @file_data = file_data || read if exist?
        @options = options || {}
      end

      def exist?
        self.class.exist?(file_path: file_path)
      end

      def read
        self.file_data = self.class.read(file_path: file_path)
      end

      def read!
        self.file_data = self.class.read!(file_path: file_path)
      end

      def write!(file_data:)
        self.class.write!(file_data: file_data, file_path: file_path)
      end

      def write(file_data:)
        self.class.write(file_data: file_data, file_path: file_path)
      end

      def delete!
        self.class.delete!(file_path: file_path)
      end

      def delete
        self.class.delete(file_path: file_path)
      end

      def version
        self.class.version(file_path: file_path)
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
          File.read(file_path) if exist?(file_path: file_path)
        end

        def write!(file_data:, file_path:)
          raise file_already_exists_message(file_path: file_path) if exist?(file_path: file_path)

          write(file_data: file_data, file_path: file_path)
        end

        def write(file_data:, file_path:)
          raise ArgumentError, 'file_data is nil' if file_data.nil?
          raise ArgumentError, "file_data is the wrong object type:\"#{file_data}\"" unless file_data.is_a?(String)

          File.write(file_path, file_data)
        end

        def delete!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless delete(file_path: file_path)
        end

        def delete(file_path:)
          return false unless exist?(file_path: file_path)

          File.delete(file_path)

          true
        end

        def version(file_path:)
          raise NotImplementedError, 'You must implement the version method in your subclass'
        end

        private

        attr_reader :options

        def file_does_not_exist_message(file_path:)
          "File \"#{file_path}\" does not exist"
        end

        def file_already_exists_message(file_path:)
          "File \"#{file_path}\" already exists"
        end
      end
    end
  end
end
