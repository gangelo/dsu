# frozen_string_literal: true

require_relative '../../models/entry'

module Dsu
  module Services
    module Entry
      class HydratorService
        def initialize(entries_array:, options: {})
          raise ArgumentError, 'entries_array is nil' if entries_array.nil?
          unless entries_array.is_a?(Array)
            raise ArgumentError, "entries_array is the wrong object type: \"#{entries_array}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @entries_array = entries_array
          @options = options || {}
        end

        def call
          hydrate
        end

        private

        attr_reader :entries_array, :options

        def hydrate
          entries_array.map do |entry_hash|
            Dsu::Models::Entry.new(**entry_hash)
          end
        end
      end
    end
  end
end
