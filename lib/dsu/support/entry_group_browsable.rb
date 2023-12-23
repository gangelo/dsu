# frozen_string_literal: true

require_relative '../models/configuration'
require_relative '../services/entry_group/browse_service'
require_relative '../services/entry_group/counter_service'

module Dsu
  module Support
    module EntryGroupBrowsable
      def browse_entry_groups(time:, options: {})
        raise ArgumentError, 'time must be a Time object' unless time.is_a?(Time)
        raise ArgumentError, 'options must be a Hash' unless options.is_a?(Hash)

        options = configuration.to_h.merge(options).with_indifferent_access
        times = browse_service(time: time, options: options).call
        if times.empty? || (options.fetch(:include_all, false) && no_entries_for?(times: times, options: options))
          display_no_entries_to_display_message time: time, options: options
          return
        end

        output = Services::StdoutRedirectorService.call do
          self.class.display_dsu_header
          header = browse_header_for(time: time, options: options)
          Views::Shared::Info.new(messages: header).render
          puts
          view_entry_groups(times: times, options: options)
          self.class.display_dsu_footer
        end
        output_with_pager output: output, options: options
      end

      private

      def no_entries_for?(times:, options:)
        Services::EntryGroup::CounterService.new(times: times, options: options).call.zero?
      end

      def browse_header_for(time:, options:)
        of, times = case options[:browse]
        when :week
          [
            I18n.t('subcommands.browse.headers.week_of', week: time.beginning_of_week.to_date),
            [time.beginning_of_week, time.end_of_week]
          ]
        when :month
          [
            I18n.t('subcommands.browse.headers.month_of', month: I18n.l(time, format: '%B')),
            [time.beginning_of_month, time.end_of_month]
          ]
        when :year
          [
            I18n.t('subcommands.browse.headers.year_of', year: time.to_date.year),
            [time.beginning_of_year, time.end_of_year]
          ]
        end

        I18n.t('subcommands.browse.headers.browsing', of: of, from: times.min.to_date.to_s, to: times.max.to_date.to_s)
      end

      def output_with_pager(output:, options:)
        if options[:pager] == false
          puts output
          return
        end

        pager_command = if RUBY_PLATFORM.match?(/win32|windows/i)
          'more' # Windows command
        else
          'less' # Unix-like command
        end

        IO.popen(pager_command, 'w') do |pipe|
          pipe.puts output
          pipe.close_write
        end
      rescue Errno::ENOENT
        message = "Operating system pager command (#{pager_command}) not found. Falling back to direct output."
        Views::Shared::Error.new(messages: message).render
        puts output
      end

      def display_no_entries_to_display_message(time:, options:)
        case options[:browse]
        when :week
          Views::EntryGroup::Shared::NoEntriesToDisplayForWeekOf.new(time: time, options: options).render
        when :month
          Views::EntryGroup::Shared::NoEntriesToDisplayForMonthOf.new(time: time, options: options).render
        when :year
          Views::EntryGroup::Shared::NoEntriesToDisplayForYearOf.new(time: time, options: options).render
        else
          raise NotImplementedError, 'Unhandled option; ' \
                                     "expected :week, :month, or :year but received #{options[:browse]}"
        end
      end

      def browse_service(time:, options: {})
        Services::EntryGroup::BrowseService.new(time: time, options: options)
      end
    end
  end
end
