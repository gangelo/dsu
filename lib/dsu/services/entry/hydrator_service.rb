# frozen_string_literal: true

require_relative '../../models/entry'

module Dsu
  module Services
    module Entry
      class HydratorService
        def initialize(entries_array:, options: {})
          raise ArgumentError, 'entries_array is nil' if entries_array.nil?
          raise ArgumentError, 'options is nil' if options.nil?

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
