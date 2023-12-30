# frozen_string_literal: true

module Dsu
  module Presenters
    module Export
      module Messages
        def display_export_prompt
          raise NotImplementedError
        end

        def display_nothing_to_export_message
          puts apply_theme(I18n.t('subcommands.export.messages.nothing_to_export'), theme_color: color_theme.info)
        end

        private

        def display_cancelled_message
          puts apply_theme(I18n.t('subcommands.export.messages.cancelled'), theme_color: color_theme.info)
        end

        def display_exported_message
          puts apply_theme(I18n.t('subcommands.export.messages.exported'), theme_color: color_theme.success)
        end

        def display_exported_to_message(file_path:)
          puts apply_theme(I18n.t('subcommands.export.messages.exported_to', file_path: file_path),
            theme_color: color_theme.success)
        end
      end
    end
  end
end
