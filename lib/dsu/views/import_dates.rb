# frozen_string_literal: true

require_relative 'import'

module Dsu
  module Views
    class ImportDates < Import
      private

      def import_prompt
        I18n.t('subcommands.import.prompts.import_dates_confirm',
          from: presenter.from.to_date, to: presenter.to.to_date,
          count: presenter.import_entry_groups_count, project: presenter.project_name)
      end
    end
  end
end
