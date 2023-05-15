# frozen_string_literal: true

require 'time'
require 'active_support/core_ext/numeric/time'
require_relative '../../../models/edited_entry'
require_relative '../../../support/time_formatable'

module Dsu
  module Views
    module EditedEntries
      module Shared
        class Warnings
          include Support::Colorable
          include Support::Say
          include Support::TimeFormatable

          def initialize(warnings:, options: {})
            # raise ArgumentError, 'edited_entries is nil' if edited_entries.nil?
            # raise ArgumentError, 'edited_entries is the wrong object type' unless edited_entries.is_a?(Array)
            # unless edited_entries.all?(Models::EditedEntry)
            #   raise ArgumentError, 'edited_entries elements are the wrong object type'
            # end
            # raise ArgumentError, 'options is nil' if options.nil?
            # raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

            @warnings = warnings
            @options = options || {}
            @header = options[:header] || 'The following WARNINGS were encountered; these changes were not saved:'
          end

          def render
            duplicate_entry_warnings
          end

          def duplicate_entry_warnings
            return if warnings.empty?
            return if warnings[:duplicates].empty?

            say header, WARNING

            warnings[:duplicates].each_with_index do |duplicate, index|
              say "#{index + 1}. Description for this entry already exists within the entry group: " \
                  "\"#{duplicate.short_description}\".", WARNING
            end
          end

          private

          attr_reader :warnings, :header, :options
        end
      end
    end
  end
end
