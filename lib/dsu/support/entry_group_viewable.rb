# frozen_string_literal: true

module Dsu
  module Support
    module EntryGroupViewable
      def view_entry_groups(times:, options: {})
        raise ArgumentError, 'times must be an Array' unless times.is_a?(Array)
        raise ArgumentError, 'Options must be a Hash' unless options.is_a?(Hash)

        total_viewable_entry_groups = 0

        times.each do |time|
          view_entry_group(time: time, options: options) do
            total_viewable_entry_groups += 1
            puts
          end
        end

        total_unviewable_entry_groups = times.size - total_viewable_entry_groups
        yield total_viewable_entry_groups, total_unviewable_entry_groups if block_given?
      end

      def view_entry_group(time:, options: {})
        return unless show_entry_group?(time: time, options: options)

        entry_group = Models::EntryGroup.find_or_create(time: time)
        Views::EntryGroup::Show.new(entry_group: entry_group).render

        yield if block_given?
      end

      private

      def show_entry_group?(time:, options:)
        Models::EntryGroup.exist?(time: time) || options[:include_all]
      end

      module_function :view_entry_group, :view_entry_groups, :show_entry_group?
    end
  end
end
