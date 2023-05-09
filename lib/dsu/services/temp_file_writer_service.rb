# frozen_string_literal: true

require 'tempfile'

module Dsu
  module Services
    class TempFileWriterService
      def initialize(temp_file_content:, options: {})
        raise ArgumentError, 'temp_file_content is nil' if temp_file_content.nil?
        raise ArgumentError, 'temp_file_content is the wrong object type' unless temp_file_content.is_a?(String)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @temp_file_content = temp_file_content
        @options = options || {}
      end

      def call
        raise ArgumentError, 'no block given' unless block_given?

        Tempfile.new('dsu').tap do |file|
          file.write("#{temp_file_content}\n")
          file.close
          yield file.path
        end.unlink
      end

      private

      attr_reader :temp_file_content, :options
    end
  end
end
