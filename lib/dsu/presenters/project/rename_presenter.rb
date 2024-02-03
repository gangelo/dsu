# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class RenamePresenter < BasePresenterEx
        attr_reader :project_name, :new_project_name, :new_project_description

        def initialize(project_name:, new_project_name:, new_project_description:, options: {})
          super(options: options)

          raise ArgumentError, 'project_name is blank' if project_name.blank?
          raise ArgumentError, 'new_project_name is blank' if new_project_name.blank?

          self.project_name = project_name.strip
          self.new_project_name = new_project_name.strip
          self.new_project_description = new_project_description&.strip
        end

        def respond(response:)
          return false unless response

          project.rename(project_name: :project_name, description: description) if project_already_exists?
        end

        def project_already_exists?
          project.exist?
        end

        def project_errors
          return false unless project.persisted?

          project.errors.full_messages
        end

        private

        attr_writer :project_name, :description

        def project
          @project ||= Models::Project.find_or_initialize(project_name: project_name)
        end
      end
    end
  end
end
