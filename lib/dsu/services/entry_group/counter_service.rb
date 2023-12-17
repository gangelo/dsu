# frozen_string_literal: true

require_relative '../../models/entry_group'

module Dsu
  module Services
    module EntryGroup
      class CounterService
        def initialize(times:, options: {})
          raise ArgumentError, 'Argument times is nil' if times.nil?

          @times = times
          @options = options
        end

        def call
          total_entry_groups = 0

          times.each do |time|
            total_entry_groups += 1 if Models::EntryGroup.exist?(time: time)
          end

          total_entry_groups
        end

        private

        attr_reader :times, :options
      end
    end
  end
end
