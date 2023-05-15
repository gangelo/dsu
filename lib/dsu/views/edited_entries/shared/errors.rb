# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../../models/edited_entry'
require_relative '../../../support/time_formatable'

module Dsu
  module Views
    module EditedEntries
      module Shared
        class Errors
          include Support::Colorable
          include Support::Say
          include Support::TimeFormatable

          def initialize(edited_entries:, options: {})
            raise ArgumentError, 'edited_entries is nil' if edited_entries.nil?
            raise ArgumentError, 'edited_entries is the wrong object type' unless edited_entries.is_a?(Array)
            unless edited_entries.all?(Models::EditedEntry)
              raise ArgumentError, 'edited_entries elements are the wrong object type'
            end
            raise ArgumentError, 'options is nil' if options.nil?
            raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

            @edited_entries = edited_entries
            @options = options || {}
            @header = options[:header] || 'The following ERRORS were encountered; these changes were not saved:'
          end

          def render
            return if edited_entries.empty?
            return if edited_entries.all?(&:valid?)

            say header, ERROR

            edited_entries.each_with_index do |edited_entry, index|
              edited_entry.errors.full_messages.each { |message| say "#{index + 1}. #{message}", ERROR }
            end
          end

          private

          attr_reader :edited_entries, :header, :options
        end
      end
    end
  end
end
