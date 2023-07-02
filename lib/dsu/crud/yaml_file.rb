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
          raise file_does_not_exist_message(file_path: file_path) unless exist?(file_path: file_path)

          read(file_path: file_path)
        end

        def read(file_path:)
          file_data = super.read(file_path: file_path) || ''
          file_hash = YAML.safe_load(ERB.new(file_data).result)

          yield file_hash if block_given?

          file_hash
        end

        def write!(file_hash:, file_path:)
          super.write(file_data: file_hash, file_path: file_path)
        end

        def write(file_hash:, file_path:)
          super.write(file_data: file_hash&.to_yaml, file_path: file_path)
        end
      end
    end
  end
end
