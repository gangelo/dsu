# frozen_string_literal: true

require 'active_model'
require_relative '../crud/entry_group/'
require_relative '../services/entry_group/editor_service'
require_relative '../support/time_formatable'
require_relative '../validators/entries_validator'
require_relative '../validators/time_validator'
require_relative 'entry'

module Dsu
  module Models
    # This class represents a group of entries for a given day. IOW,
    # things someone might want to share at their daily standup (DSU).
    class EntryGroup
      include ActiveModel::Model
      include Crud::EntryGroup
      include Support::TimeFormatable

      attr_accessor :time
      attr_reader :entries

      validates_with Validators::EntriesValidator
      validates_with Validators::TimeValidator

      def initialize(time: nil, entries: [])
        raise ArgumentError, 'time is the wrong object type' unless time.is_a?(Time) || time.nil?

        @time = ensure_local_time(time)
        self.entries = entries || []
      end

      class << self
        def edit(time:, options: {})
          # NOTE: Uncomment this line to prohibit edits on
          # Entry Groups that do not exist (i.e. have no entries).
          # return new(time: time) unless exists?(time: time)

          find_or_create(time: time).tap do |entry_group|
            Services::EntryGroup::EditorService.new(entry_group: entry_group, options: options).call
          end
        end
      end

      def valid_unique_entries
        entries&.select(&:valid?)&.uniq(&:description)
      end

      def clone
        self.class.new(time: time, entries: entries.map(&:clone))
      end

      def entries=(entries)
        entries ||= []

        raise ArgumentError, 'entries is the wrong object type' unless entries.is_a?(Array)
        raise ArgumentError, 'entries contains the wrong object type' unless entries.all?(Entry)

        @entries = entries.map(&:clone)
      end

      def time_formatted
        formatted_time(time: time)
      end

      def to_h
        {
          time: time.dup,
          entries: entries.map(&:to_h)
        }
      end

      private

      def ensure_local_time(time)
        time.nil? ? Time.now : time.dup.localtime
      end
    end
  end
end
