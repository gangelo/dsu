# frozen_string_literal: true

require_relative '../support/entry_group_fileable'

module Dsu
  module Services
    class EntryGroupReaderService
      include Dsu::Support::EntryGroupFileable

      def initialize(time:, options: {})
        @time = time
        @options = options || {}
      end

      def call
        read_entry_group_file
      end

      class << self
        def entry_group_file_exists?(time:, options: {})
          new(time: time, options: options).send(:entry_group_file_exists?)
        end
      end

      private

      attr_reader :time, :options

      def read_entry_group_file
        return {} unless entry_group_file_exists?

        File.read(entry_group_file_path)
      end
    end
  end
end
