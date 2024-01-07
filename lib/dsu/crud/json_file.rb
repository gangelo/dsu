# frozen_string_literal: true

require 'active_model'
require 'json'

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

      def file_exist?
        self.class.file_exist?(file_path: file_path)
      end

      def persisted?
        file_exist?
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
        def file_exist?(file_path:)
          File.exist?(file_path)
        end

        def delete(file_path:)
          return false unless file_exist?(file_path: file_path)

          File.delete(file_path)

          true
        end

        def delete!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless delete(file_path: file_path)
        end

        def parse(json)
          return if json.nil?

          JSON.parse(json, symbolize_names: true)
        end

        def read(file_path:)
          json = File.read(file_path) if file_exist?(file_path: file_path)
          hash = parse(json)
          return yield hash if hash && block_given?

          hash
        end

        def read!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless file_exist?(file_path: file_path)

          hash = read(file_path: file_path)
          return yield hash if hash && block_given?

          hash
        end

        def write(file_data:, file_path:)
          raise ArgumentError, 'file_data is nil' if file_data.nil?
          raise ArgumentError, "file_data is the wrong object type:\"#{file_data}\"" unless file_data.is_a?(Hash)

          file_data = JSON.pretty_generate(file_data)
          File.write(file_path, file_data)
        end

        def write!(file_data:, file_path:)
          write(file_data: file_data, file_path: file_path)
        end

        def file_does_not_exist_message(file_path:)
          "File \"#{file_path}\" does not exist"
        end
      end

      private

      attr_writer :file_path, :version

      def read
        hash = self.class.read(file_path: file_path)
        return yield hash if block_given?

        hash
      end

      def read!
        hash = self.class.read!(file_path: file_path)
        return yield hash if hash && block_given?

        hash
      end

      def read_version
        return 0 unless file_exist?

        hash = read
        return 0 if hash.nil?

        hash.fetch(:version, 0).to_i
      end
    end
  end
end
