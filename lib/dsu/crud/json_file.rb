# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative 'raw_file'

module Dsu
  module Crud
    class JsonFile < RawFile
      def write!(file_hash:)
        self.class.write!(file_hash: file_hash, file_path: file_path)
      end

      def write(file_hash:)
        self.class.write(file_hash: file_hash, file_path: file_path)
      end

      class << self
        def read!(file_path:)
          file_hash = parse_json(superclass.read!(file_path: file_path))
          yield file_hash if block_given?

          file_hash
        end

        def read(file_path:)
          file_hash = parse_json(superclass.read(file_path: file_path))
          yield file_hash if block_given?

          file_hash
        end

        def write!(file_hash:, file_path:)
          raise ArgumentError, 'file_hash is nil' if file_hash.nil?
          raise ArgumentError, "file_hash is the wrong object type:\"#{file_hash}\"" unless file_hash.is_a?(Hash)

          file_data = JSON.pretty_generate(file_hash) if file_hash
          superclass.write!(file_data: file_data, file_path: file_path)
        end

        def write(file_hash:, file_path:)
          raise ArgumentError, 'file_hash is nil' if file_hash.nil?
          raise ArgumentError, "file_hash is the wrong object type:\"#{file_hash}\"" unless file_hash.is_a?(Hash)

          file_data = JSON.pretty_generate(file_hash) if file_hash
          superclass.write(file_data: file_data, file_path: file_path)
        end

        def version(file_path:)
          read(file_path: file_path).fetch(:version, 0).to_i
        end

        private

        def parse_json(file_data)
          return {} if file_data.nil?

          JSON.parse(file_data, symbolize_names: true)
        end
      end
    end
  end
end
