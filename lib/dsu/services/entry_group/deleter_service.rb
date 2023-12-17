# frozen_string_literal: true

require_relative '../../models/entry_group'

module Dsu
  module Services
    module EntryGroup
      class DeleterService
        def initialize(times:, options: {})
          raise ArgumentError, 'Argument times is nil' if times.nil?

          @times = times
          @options = options
        end

        def call
          deleted_entry_groups = 0

          times.each do |time|
            next unless Models::EntryGroup.exist?(time: time)

            Models::EntryGroup.delete(time: time)
            deleted_entry_groups += 1
          end

          deleted_entry_groups
        end

        private

        attr_reader :times, :options
      end
    end
  end
end
