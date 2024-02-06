# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../../support/fileable'

module Dsu
  module Services
    module Project
      class RenameService
        def initialize(from_project_name:, to_project_name:, to_project_description:, options: {})
          @from_project_name = from_project_name
          @to_project_name = to_project_name
          @to_project_description = to_project_description
          @options = options
        end

        def call
          validate!

          # NOTE: The default and current states need to be captured before
          # the project is renamed.
          rename!(
            make_default: Models::Project.default_project?(project_name: from_project_name),
            make_current: Models::Project.current_project?(project_name: from_project_name)
          )
        end

        private

        attr_reader :from_project_name, :to_project_name, :to_project_description, :options

        def rename!(make_default:, make_current:)
          move_project

          Models::Project.update(project_name: to_project_name,
            description: to_project_description, options: options).tap do |project|
            project.default! if make_default
            project.use! if make_current
          end
        end

        def move_project
          FileUtils.mv(Support::Fileable.project_folder_for(project_name: from_project_name), temp_project_folder)
          FileUtils.mv(temp_project_folder, Support::Fileable.project_folder_for(project_name: to_project_name))
        end

        def temp_project_folder
          @temp_project_folder ||= Support::Fileable.project_folder_for(project_name: SecureRandom.uuid)
        end

        def validate!
          validate_from_project_name!
          validate_to_project_name!
        end

        def validate_from_project_name!
          unless Models::Project.project_file_exist?(project_name: from_project_name)
            raise I18n.t('models.project.errors.does_not_exist', project_name: from_project_name)
          end
        end

        def validate_to_project_name!
          if Models::Project.project_file_exist?(project_name: to_project_name)
            raise I18n.t('models.project.errors.new_project_already_exists', project_name: to_project_name)
          end
        end
      end
    end
  end
end
