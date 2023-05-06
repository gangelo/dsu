# frozen_string_literal: true

require_relative '../models/entry'

module Dsu
  module Services
    class EntryHydratorService
      def initialize(entry_hash:, options: {})
        raise ArgumentError, 'entry_hash is nil' if entry_hash.nil?
        raise ArgumentError, 'entry_hash is the wrong object type' unless entry_hash.is_a?(Hash)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @entry_hash = entry_hash
        @options = options || {}
      end

      def call
        Dsu::Models::Entry.new(**entry_hash)
      end

      class << self
        def hydrate(entries_array:, options: {})
          entries_array.map do |entry_hash|
            new(entry_hash: entry_hash, options: options).call
          end
        end
      end

      private

      attr_reader :entry_hash, :options
    end
  end
end
