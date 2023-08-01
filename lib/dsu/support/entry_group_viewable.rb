# frozen_string_literal: true

module Dsu
  module Support
    module EntryGroupViewable
      def view_entry_groups(times:, options: {})
        raise ArgumentError, 'times must be an Array' unless times.is_a?(Array)
        raise ArgumentError, 'options must be a Hash' unless options.is_a?(Hash)

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
        raise ArgumentError, 'time must be a Time object' unless time.is_a?(Time)
        raise ArgumentError, 'options must be a Hash' unless options.is_a?(Hash)

        return unless show_entry_group?(time: time, options: options)

        entry_group = Models::EntryGroup.find_or_initialize(time: time)
        Views::EntryGroup::Show.new(entry_group: entry_group).render

        yield if block_given?
      end

      # This method will unconditionally display the FIRST and LAST entry groups
      # associated with the times provided by the <times> argument. All other
      # entry groups will be conditionally displayed based on the :include_all
      # value in the <options> argument.
      def view_list_for(times:, options:)
        configuration = Models::Configuration.instance unless defined?(configuration) && configuration
        options = configuration.to_h.merge(options).with_indifferent_access
        times_first_and_last = [times.first, times.last]
        times.each do |time|
          view_options = options.dup
          view_options[:include_all] = true if times_first_and_last.include?(time)
          view_entry_group(time: time, options: view_options) do
            puts
          end
        end
      end

      private

      def show_entry_group?(time:, options:)
        Models::EntryGroup.exist?(time: time) || options[:include_all]
      end

      module_function :view_entry_group, :view_entry_groups, :view_list_for, :show_entry_group?
    end
  end
end
