# frozen_string_literal: true

require_relative '../base_list_view'

module Dsu
  module Views
    module Project
      # TODO: I18n.
      class List < Views::BaseListView
        NO_JUSTIFICATION = 4
        PROJECT_JUSTIFICATION = 15
        DEFAULT_JUSTIFICATION = 10
        CURRENT_JUSTIFICATION = 10
        DESCRIPTION_JUSTIFICATION = 10

        DETAIL_HEADER_STRING = "#{'No.'.ljust(NO_JUSTIFICATION)} " \
                               "#{'Project'.ljust(PROJECT_JUSTIFICATION)} " \
                               "#{'Default'.center(DEFAULT_JUSTIFICATION)} " \
                               "#{'Current'.center(CURRENT_JUSTIFICATION)} " \
                               "#{'Description'.ljust(DESCRIPTION_JUSTIFICATION)}".freeze

        def render
          super do
            return display_no_projects if presenter.projects.none?

            display_project_list
          end
        end

        private

        def display_project_list
          display_header
          display_detail_header
          display_detail
          display_footer
        end

        def display_no_projects
          # Should never happen
          message = I18n.t('subcommands.project.messages.no_projects')
          puts apply_theme(message, theme_color: color_theme.info)
        end

        def display_detail
          presenter.projects.each_with_index do |project, index|
            display_detail_data(
              formatted_index(index: index),
              project.project_name,
              project.default_project?,
              project.current_project?,
              project.description
            )
          end
        end

        def display_detail_header
          puts apply_theme(DETAIL_HEADER_STRING, theme_color: color_theme.index)
        end

        def display_detail_data(index, project_name, default_project, current_project, project_desc)
          puts "#{index_detail_data(index)} " \
               "#{project_name_detail_data(project_name)} " \
               "#{project_default_detail_data(default_project)} " \
               "#{project_current_detail_data(current_project)} " \
               "#{project_desc_detail_data(project_desc)}"
        end

        # def display_detail_data(index, project_name, default_project, current_project, project_desc)
        #   puts "#{index_detail_data(index)}|" \
        #        "#{project_name_detail_data(project_name)}|" \
        #        "#{project_default_detail_data(default_project)}|" \
        #        "#{project_current_detail_data(current_project)}|" \
        #        "#{project_desc_detail_data(project_desc)}"
        # end

        def display_footer
          footer = "\nTotal projects: #{presenter.projects.count}"
          puts apply_theme(footer, theme_color: color_theme.footer)
        end

        def display_header
          header = "Project list\n"
          puts apply_theme(header, theme_color: color_theme.subheader)
        end

        def index_detail_data(value)
          apply_theme(value.to_s.ljust(NO_JUSTIFICATION), theme_color: color_theme.index)
        end

        def project_name_detail_data(value)
          apply_theme(value.to_s.ljust(PROJECT_JUSTIFICATION), theme_color: color_theme.body.bold!)
        end

        def project_default_detail_data(value)
          value = value ? '*' : ' '
          apply_theme(value.to_s.center(DEFAULT_JUSTIFICATION), theme_color: color_theme.body.bold!)
        end

        def project_current_detail_data(value)
          value = value ? '*' : ' '
          apply_theme(value.to_s.center(CURRENT_JUSTIFICATION), theme_color: color_theme.body.bold!)
        end

        def project_desc_detail_data(value)
          apply_theme(value.to_s.ljust(DESCRIPTION_JUSTIFICATION), theme_color: color_theme.body)
        end

        def theme_name
          @theme_name ||= options.fetch(:theme_name, Models::Configuration.new.theme_name)
        end
      end
    end
  end
end
