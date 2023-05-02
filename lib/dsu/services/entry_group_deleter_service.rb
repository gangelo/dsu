# frozen_string_literal: true

require_relative '../support/entry_group_fileable'

# This class is responsible for deleting an entry group file.
module Dsu
  module Services
    class EntryGroupDeleterService
      include Dsu::Support::EntryGroupFileable

      def initialize(time:, options: {})
        @time = time
        @options = options || {}
      end

      def call
        delete_entry_group_file!
      end

      private

      attr_reader :time, :options

      def delete_entry_group_file!
        return unless entry_group_file_exists?

        File.delete(entry_group_file_path)
      end
    end
  end
end
