# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../services/entry_group/importer_service'
require_relative '../../support/ask'
require_relative '../base_presenter_ex'
require_relative 'import_file'
require_relative 'messages'
require_relative 'service_callable'

module Dsu
  module Presenters
    module Import
      class DatesPresenter < BasePresenterEx
        include ImportFile
        include Messages
        include ServiceCallable
        include Support::Ask

        def initialize(from:, to:, import_file_path:, options: {})
          super(options: options)

          @from = from.beginning_of_day
          @to = to.end_of_day
          @import_file_path = import_file_path
        end

        def render(response:)
          return display_cancelled_message unless response

          importer_service_call.tap do |import_results|
            if import_results.values.all?(&:empty?)
              display_import_success_message
            else
              display_import_error_message import_results
            end
          end
        end

        def display_import_prompt
          yes?(prompt_with_options(prompt: import_prompt, options: import_prompt_options), options: options)
        end

        private

        attr_reader :from, :to, :import_file_path, :options

        def import_entry_groups
          @import_entry_groups ||= CSV.foreach(import_file_path,
            headers: true).with_object({}) do |entry_group_entry, entry_groups_hash|
            next unless entry_group_entry['version'].to_i == Dsu::Migration::VERSION

            entry_group_time = middle_of_day_for(entry_group_entry['entry_group'])
            next unless entry_group_time.to_date.between?(from.to_date, to.to_date)

            entry_group_time.to_date.to_s.tap do |time|
              entry_groups_hash[time] = [] unless entry_groups_hash.key?(time)
              entry_groups_hash[time] << entry_group_entry['entry_group_entry']
            end
          end
        end

        def import_prompt
          I18n.t('subcommands.import.prompts.import_dates_confirm',
            from: from.to_date, to: to.to_date, count: import_entry_groups.keys.count)
        end

        def import_prompt_options
          I18n.t('subcommands.import.prompts.options')
        end

        def middle_of_day_for(date_string)
          Time.parse(date_string).in_time_zone.middle_of_day
        end
      end
    end
  end
end
