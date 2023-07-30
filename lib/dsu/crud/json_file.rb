# frozen_string_literal: true

require 'active_model'
require 'json'
require_relative 'raw_json_file'

module Dsu
  module Crud
    class JsonFile
      include ActiveModel::Model

      attr_reader :file_path

      def initialize(file_path)
        @file_path = file_path
      end

      def delete
        self.class.delete(file_path: file_path)
      end

      def delete!
        self.class.delete!(file_path: file_path)
      end

      def exist?
        self.class.exist?(file_path: file_path)
      end

      def persisted?
        exist?
      end

      # Override this method to reload data from the file
      def reload
        @version = read_version

        self
      end

      def to_h
        raise NotImplementedError, 'You must implement this method in a your subclass'
      end

      def to_model
        self
      end

      def version
        @version ||= read_version
      end

      def write
        return false unless valid?

        self.class.write(file_data: to_h, file_path: file_path)
        true
      end

      def write!
        validate!

        self.class.write(file_data: to_h, file_path: file_path)
      end

      alias save write
      alias save! write!

      class << self
        def exist?(file_path:)
          RawJsonFile.exist?(file_path: file_path)
        end

        def delete(file_path:)
          RawJsonFile.delete(file_path: file_path)
        end

        def delete!(file_path:)
          RawJsonFile.delete!(file_path: file_path)
        end

        def parse(json)
          return if json.nil?

          JSON.parse(json, symbolize_names: true)
        end

        def read(file_path:)
          hash = parse(RawJsonFile.read(file_path: file_path))
          return yield hash if hash && block_given?

          hash
        end

        def read!(file_path:)
          hash = parse(RawJsonFile.read!(file_path: file_path))
          return yield hash if hash && block_given?

          hash
        end

        def write(file_data:, file_path:)
          Crud::RawJsonFile.write(file_data: file_data, file_path: file_path)
        end

        def write!(file_data:, file_path:)
          write(file_data: file_data, file_path: file_path)
        end
      end

      private

      def read
        hash = self.class.parse(RawJsonFile.read(file_path: file_path))
        return yield hash if block_given?

        hash
      end

      def read!
        hash = self.class.parse(RawJsonFile.read!(file_path: file_path))
        return yield hash if hash && block_given?

        hash
      end

      def read_version
        return 0 unless exist?

        hash = read
        return 0 if hash.nil?

        hash.fetch(:version, 0).to_i
      end

      attr_writer :file_path, :version
    end
  end
end
