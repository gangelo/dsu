# frozen_string_literal: true

require_relative '../support/entry'
require_relative '../support/entry_group_loadable'
require_relative '../support/folder_locations'

module Dsu
  module CommandServices
    class Add
      include Dsu::Support::EntryGroupLoadable
      include Dsu::Support::FolderLocations

      attr_reader :entry, :date

      def initialize(entry:, date:)
        @entry = entry
        @date = date
      end

      def call
        entry.validate!
        save_entry_group! unless entry_exists?
        entry.uuid
      rescue ActiveModel::ValidationError
        puts "Error(s) encountered: #{entry.errors.full_messages}"
        raise
      end

      private

      attr_writer :entry, :date

      def entry_exists?
        @entry_exists ||= entry_group_hash[:entries].any? { |e| e[:uuid] == entry.uuid }
      end

      def entry_group_hash
        @entry_group_hash ||= entry_group_hash_for time: date
      end

      def save_entry_group!
        raise "Entry #{entry.uuid} already exists in entry group #{date}" if entry_exists?

        entry_group_hash[:entries] << entry.to_h

        binding.pry
      end
    end
  end
end
