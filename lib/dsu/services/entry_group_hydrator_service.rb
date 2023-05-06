# frozen_string_literal: true

require_relative 'entry_hydrator_service'

module Dsu
  module Services
    class EntryGroupHydratorService
      def initialize(entry_group_json:, options: {})
        raise ArgumentError, 'entry_group_json is nil' if entry_group_json.nil?
        raise ArgumentError, 'entry_group_json is the wrong object type' unless entry_group_json.is_a?(String)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @entry_group_json = entry_group_json
        @options = options || {}
      end

      def call
        entry_group_hash = to_h
        Dsu::Models::EntryGroup.new(**entry_group_hash)
      end

      class << self
        # Returns a Hash with :time and :entries values hydrated
        # (i.e. Time and Entry objects respectively).
        def to_h(entry_group_json:, options: {})
          JSON.parse(entry_group_json, symbolize_names: true).tap do |hash|
            hash[:time] = Time.parse(hash[:time])
            hash[:entries] = EntryHydratorService.hydrate(entries_array: hash[:entries], options: options)
          end
        end
      end

      private

      attr_reader :entry_group_json, :options

      def to_h
        self.class.to_h(entry_group_json: entry_group_json, options: options)
      end
    end
  end
end
