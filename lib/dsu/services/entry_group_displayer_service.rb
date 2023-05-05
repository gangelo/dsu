# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../support/entry_group'
require_relative '../support/say'

module Dsu
  module Services
    class EntryGroupDisplayerService
      include Dsu::Support::Say

      def initialize(entry_group:, options: {})
        raise ArgumentError, 'entry_group is nil' if entry_group.nil?
        raise ArgumentError, 'entry_group is the wrong object type' unless entry_group.is_a?(Dsu::Support::EntryGroup)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @entry_group = entry_group
        @options = options || {}
      end

      def call
        # Just in case the entry group is invalid, we'll
        # validate it before displaying it.
        entry_group.validate!
        display_entry_group!
      rescue ActiveModel::ValidationError
        puts "Error(s) encountered: #{entry_group.errors.full_messages}"
        raise
      end

      private

      attr_reader :entry_group, :options

      def display_entry_group!
        say format_time(time: entry_group.time), :green
        entry_group.entries.each_with_index do |entry, index|
          prefix = "#{format('%03d', index + 1)}. #{entry.uuid}"
          say "#{prefix} :#{entry.description}"
          say "#{''.ljust(prefix.length)} :#{entry.long_description}" if entry.long_description?
        end
      end

      # TODO: Move this to a module
      def format_time(time:)
        time = time.localtime

        special = if today?(time: time)
          'Today'
        elsif yesterday?(time: time)
          'Yesterday'
        elsif tomorrow?(time: time)
          'Tomorrow'
        end

        return time.strftime('%A, %Y-%m-%d') unless special

        "#{special} #{time.strftime('(%A, %Y-%m-%d)')}"
      end

      def today?(time:)
        time.utc.strftime('%Y%m%d') == Time.now.utc.strftime('%Y%m%d')
      end

      def yesterday?(time:)
        time.utc.strftime('%Y%m%d') == 1.day.ago(Time.now).utc.strftime('%Y%m%d')
      end

      def tomorrow?(time:)
        time.utc.strftime('%Y%m%d') == 1.from_now(Time.now).utc.strftime('%Y%m%d')
      end
    end
  end
end
