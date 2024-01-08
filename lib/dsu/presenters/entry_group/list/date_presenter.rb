# frozen_string_literal: true

require_relative '../../../models/configuration'
require_relative '../../../models/entry_group'
require_relative '../../../views/entry_group/shared/no_entries_to_display'
require_relative '../../base_presenter_ex'
require_relative 'messages'
require_relative 'nothing_to_list'

module Dsu
  module Presenters
    module EntryGroup
      module List
        class DatePresenter < BasePresenterEx
          include Messages
          include NothingToList

          def initialize(times:, options: {})
            raise ArgumentError, 'times must be an Array' unless times.is_a?(Array)
            raise ArgumentError, 'options must be a Hash' unless options.is_a?(Hash)

            super(options: options)

            @times = times
          end

          def render
            return if nothing_to_list?

            entry_groups.each do |entry_group|
              Views::EntryGroup::Show.new(entry_group: entry_group).render
              puts
            end
          end

          def display_nothing_to_list_message
            return if times_min_max_are_same?

            raise 'display_nothing_to_list_message called when there are entries to display' if entry_groups.any?

            Views::EntryGroup::Shared::NoEntriesToDisplay.new(times: times, options: options).render
          end

          private

          attr_reader :times

          def entry_groups
            @entry_groups ||= begin
              options = configuration.to_h.merge(self.options).with_indifferent_access

              times.filter_map do |time|
                view_options = options.dup
                # Always show the first and last entry groups.
                view_options[:include_all] = true if times_min_max.include?(time)

                next unless show_entry_group?(time: time, options: view_options)

                Models::EntryGroup.find_or_initialize(time: time)
              end
            end
          end

          def times_min_max
            @times_min_max ||= times.minmax
          end

          def times_min_max_are_same?
            times_min_max[0] == times_min_max[1]
          end

          def configuration
            @configuration ||= Models::Configuration.new
          end

          def show_entry_group?(time:, options:)
            Models::EntryGroup.exist?(time: time) || options[:include_all]
          end
        end
      end
    end
  end
end
