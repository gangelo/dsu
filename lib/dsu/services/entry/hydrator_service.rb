# frozen_string_literal: true

require_relative '../../models/entry'

module Dsu
  module Services
    module Entry
      class HydratorService
        def initialize(entries_json:, options: {})
          raise ArgumentError, 'entries_json is nil' if entries_json.nil?
          raise ArgumentError, 'entries_json is the wrong object type' unless entries_json.is_a?(String)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

          @entries_json = entries_json
          @options = options || {}
        end

        def call
          hydrate
        end

        private

        attr_reader :entries_json, :options

        def hydrate
          entry_json.map do |entry_hash|
            Dsu::Models::Entry.new(**entry_hash)
          end
        end
      end
    end
  end
end
