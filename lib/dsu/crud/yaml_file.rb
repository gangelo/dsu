# frozen_string_literal: true

require 'fileutils'
require 'yaml'
require_relative 'raw_file'

module Dsu
  module Crud
    class YamlFile < RawFile
      def write!(file_hash:)
        self.class.write!(file_hash: file_hash, file_path: file_path)
      end

      def write(file_hash:)
        self.class.write(file_hash: file_hash, file_path: file_path)
      end

      class << self
        def read!(file_path:)
          file_hash = parse_yaml(superclass.read!(file_path: file_path))
          yield file_hash if block_given?

          file_hash
        end

        def read(file_path:)
          file_hash = parse_yaml(superclass.read(file_path: file_path))
          yield file_hash if block_given?

          file_hash
        end

        def write!(file_hash:, file_path:)
          raise ArgumentError, 'file_hash is nil' if file_hash.nil?
          raise ArgumentError, "file_hash is the wrong object type:\"#{file_hash}\"" unless file_hash.is_a?(Hash)

          file_data = file_hash&.to_yaml
          superclass.write!(file_data: file_data, file_path: file_path)
        end

        def write(file_hash:, file_path:)
          raise ArgumentError, 'file_hash is nil' if file_hash.nil?
          raise ArgumentError, "file_hash is the wrong object type:\"#{file_hash}\"" unless file_hash.is_a?(Hash)

          file_data = file_hash&.to_yaml
          superclass.write(file_data: file_data, file_path: file_path)
        end


        private

        def parse_yaml(file_data)
          return '' if file_data.nil?

          YAML.safe_load(ERB.new(file_data).result)
        end
      end
    end
  end
end
