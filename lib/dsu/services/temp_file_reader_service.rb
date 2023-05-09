# frozen_string_literal: true

module Dsu
  module Services
    class TempFileReaderService
      def initialize(temp_file_path:, options: {})
        raise ArgumentError, 'temp_file_path is nil' if temp_file_path.nil?
        raise ArgumentError, 'temp_file_path is the wrong object type' unless temp_file_path.is_a?(String)
        raise ArgumentError, 'temp_file_path is empty' if temp_file_path.empty?
        raise ArgumentError, 'temp_file_path does not exist' unless File.exist?(temp_file_path)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @temp_file_path = temp_file_path
        @options = options || {}
      end

      def call
        raise ArgumentError, 'no block given' unless block_given?

        File.foreach(temp_file_path) do |line|
          yield line.strip
        end
      end

      private

      attr_reader :temp_file_path, :options
    end
  end
end
