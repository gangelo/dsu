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
      class AllPresenter < BasePresenterEx
        include ImportFile
        include Messages
        include ServiceCallable
        include Support::Ask

        def initialize(import_file_path:, options: {})
          super(options: options)

          @import_file_path = import_file_path
        end

        def render(response:)
          return display_cancelled_message unless response

          display_import_messages importer_service_call
        end

        def display_import_prompt
          yes?(prompt_with_options(prompt: import_prompt, options: import_prompt_options), options: options)
        end

        private

        attr_reader :import_file_path, :options

        def import_entry_groups
          @import_entry_groups ||= CSV.foreach(import_file_path,
            headers: true).with_object({}) do |entry_group_entry, entry_groups_hash|
            next unless entry_group_entry['version'].to_i == Dsu::Migration::VERSION

            Date.parse(entry_group_entry['entry_group']).to_s.tap do |time|
              entry_groups_hash[time] = [] unless entry_groups_hash.key?(time)
              entry_groups_hash[time] << entry_group_entry['entry_group_entry']
            end
          end
        end

        def import_prompt
          I18n.t('subcommands.import.prompts.import_all_confirm', count: import_entry_groups.count)
        end

        def import_prompt_options
          I18n.t('subcommands.import.prompts.options')
        end
      end
    end
  end
end
