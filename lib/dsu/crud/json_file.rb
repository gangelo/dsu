# frozen_string_literal: true

require 'json'
require_relative 'raw_json_file'

module Dsu
  module Crud
    module JsonFile
      attr_reader :file_path

      class << self
        def included(base)
          base.extend(ClassMethods)
        end
      end

      def delete
        RawJsonFile.delete(file_path: file_path)
      end

      def delete!
        RawJsonFile.delete!(file_path: file_path)
      end

      def exist?
        RawJsonFile.exist?(file_path: file_path)
      end

      def read
        hash = self.class.parse(RawJsonFile.read(file_path: file_path) || '{}')
        return yield hash if block_given?

        hash
      end

      def read!
        hash = self.class.parse(RawJsonFile.read!(file_path: file_path) || '{}')
        return yield hash if block_given?

        hash
      end

      def write
        return false if respond_to?(:valid?) && !valid?

        RawJsonFile.write(file_data: to_h, file_path: file_path)
        true
      end

      def write!
        validate! if respond_to?(:validate!)
        RawJsonFile.write(file_data: to_h, file_path: file_path)
      end

      def version
        return 0 unless exist?

        hash = read
        return 0 if hash.nil?

        hash.fetch(:version, 0).to_i
      end

      alias save write
      alias save! write!

      module ClassMethods
        def parse(json)
          return if json.nil?

          JSON.parse(json, symbolize_names: true)
        end

        def read(file_path:)
          hash = parse(RawJsonFile.read(file_path: file_path) || '{}')
          return yield hash if block_given?

          hash
        end

        def read!(file_path:)
          hash = parse(RawJsonFile.read!(file_path: file_path) || '{}')
          return yield hash if block_given?

          hash
        end
      end

      private

      attr_writer :file_path, :version
    end
  end
end
