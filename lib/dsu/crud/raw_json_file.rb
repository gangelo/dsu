# frozen_string_literal: true

require 'fileutils'

module Dsu
  module Crud
    module RawJsonFile
      class << self
        def delete(file_path:)
          return false unless exist?(file_path: file_path)

          File.delete(file_path)

          true
        end

        def delete!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless delete(file_path: file_path)
        end

        def exist?(file_path:)
          File.exist?(file_path)
        end

        def read(file_path:)
          File.read(file_path) if exist?(file_path: file_path)
        end

        def read!(file_path:)
          raise file_does_not_exist_message(file_path: file_path) unless exist?(file_path: file_path)

          read(file_path: file_path)
        end

        def write(file_data:, file_path:)
          raise ArgumentError, 'file_data is nil' if file_data.nil?
          raise ArgumentError, "file_data is the wrong object type:\"#{file_data}\"" unless file_data.is_a?(Hash)

          file_data = JSON.pretty_generate(file_data)
          File.write(file_path, file_data)
        end

        private

        def file_does_not_exist_message(file_path:)
          "File \"#{file_path}\" does not exist"
        end
      end
    end
  end
end
