# frozen_string_literal: true

module Dsu
  module Presenters
    module Import
      module Messages
        def display_import_prompt
          raise NotImplementedError
        end

        def display_import_file_not_exist_message
          puts apply_theme(I18n.t('subcommands.import.messages.file_not_exist',
            file_path: import_file_path), theme_color: color_theme.info)
        end

        def display_nothing_to_import_message
          puts apply_theme(I18n.t('subcommands.import.messages.nothing_to_import'), theme_color: color_theme.info)
        end

        private

        def display_cancelled_message
          puts apply_theme(I18n.t('subcommands.import.messages.cancelled'), theme_color: color_theme.info)
        end

        def display_import_success_message
          puts apply_theme(I18n.t('subcommands.import.messages.import_success'),
            theme_color: color_theme.success)
        end

        def display_import_error_message(import_results)
          import_results.each_pair do |entry_group_date, errors|
            if errors.empty?
              puts apply_theme(I18n.t('subcommands.import.messages.import_success',
                date: entry_group_date), theme_color: color_theme.success)
            else
              errors.each do |error|
                puts apply_theme(I18n.t('subcommands.import.messages.import_error',
                  date: entry_group_date, error: error), theme_color: color_theme.error)
              end
            end
          end
        end
      end
    end
  end
end
