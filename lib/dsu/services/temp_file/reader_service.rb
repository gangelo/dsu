# frozen_string_literal: true

module Dsu
  module Services
    module TempFile
      class ReaderService
        def initialize(tmp_file_path:, options: {})
          raise ArgumentError, 'tmp_file_path is nil' if tmp_file_path.nil?
          raise ArgumentError, 'tmp_file_path is the wrong object type' unless tmp_file_path.is_a?(String)
          raise ArgumentError, 'tmp_file_path is empty' if tmp_file_path.empty?
          raise ArgumentError, 'tmp_file_path does not exist' unless File.exist?(tmp_file_path)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

          @tmp_file_path = tmp_file_path
          @options = options || {}
        end

        def call
          raise ArgumentError, 'no block given' unless block_given?

          File.foreach(tmp_file_path) do |line|
            yield line.strip
          end
        end

        private

        attr_reader :tmp_file_path, :options
      end
    end
  end
end
