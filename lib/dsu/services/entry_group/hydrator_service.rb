# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../entry/hydrator_service'

module Dsu
  module Services
    module EntryGroup
      class HydratorService
        def initialize(entry_group_json:, options: {})
          raise ArgumentError, 'entry_group_json is nil' if entry_group_json.nil?

          unless entry_group_json.is_a?(String)
            raise ArgumentError,
              "entry_group_json is the wrong object type: \"#{entry_group_json}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, "options is the wrong object type:\"#{options}\"" unless options.is_a?(Hash)

          @entry_group_json = entry_group_json
          @options = options || {}
        end

        def call
          Models::EntryGroup.new(**hydrate)
        end

        private

        attr_reader :entry_group_json, :options

        # Returns a Hash with :time and :entries values hydrated
        # (i.e. Time and Entry objects respectively).
        def hydrate
          JSON.parse(entry_group_json, symbolize_names: true).tap do |hash|
            hash[:time] = Time.parse(hash[:time])
            hash[:entries] = Entry::HydratorService.new(entries_array: hash[:entries], options: options).call
          end
        end
      end
    end
  end
end
