# frozen_string_literal: true

require 'tempfile'

module Dsu
  module Services
    class TempFileWriterService
      def initialize(tmp_file_content:, options: {})
        raise ArgumentError, 'tmp_file_content is nil' if tmp_file_content.nil?
        raise ArgumentError, 'tmp_file_content is the wrong object type' unless tmp_file_content.is_a?(String)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @tmp_file_content = tmp_file_content
        @options = options || {}
      end

      def call
        raise ArgumentError, 'no block given' unless block_given?

        Tempfile.new('dsu').tap do |file|
          file.write("#{tmp_file_content}\n")
          file.close
          yield file.path
        end.unlink
      end

      private

      attr_reader :tmp_file_content, :options
    end
  end
end
