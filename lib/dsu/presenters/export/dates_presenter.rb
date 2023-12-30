# frozen_string_literal: true

require_relative '../../models/entry_group'
require_relative '../../support/ask'
require_relative '../base_presenter_ex'
require_relative 'messages'
require_relative 'nothing_to_export'
require_relative 'service_callable'

module Dsu
  module Presenters
    module Export
      class DatesPresenter < BasePresenterEx
        include Messages
        include NothingToExport
        include ServiceCallable
        include Support::Ask

        def initialize(from:, to:, options: {})
          super(options: options)

          @from = from
          @to = to
        end

        def render(response:)
          return display_cancelled_message unless response

          export_file_path = exporter_service_call

          display_exported_message
          display_exported_to_message(file_path: export_file_path)
        end

        def display_export_prompt
          yes?(prompt_with_options(prompt: export_prompt, options: export_prompt_options), options: options)
        end

        private

        attr_reader :from, :to, :options

        def entry_groups
          Models::EntryGroup.entry_groups(between: [from, to])
        end

        def export_prompt
          I18n.t('subcommands.export.prompts.export_dates_confirm',
            from: from.to_date, to: to.to_date, count: entry_groups.count)
        end

        def export_prompt_options
          I18n.t('subcommands.export.prompts.options')
        end
      end
    end
  end
end
