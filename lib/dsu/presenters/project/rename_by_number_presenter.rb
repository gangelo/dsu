# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class RenameByNumberPresenter < BasePresenterEx
        delegate :project_name, :description, to: :project, allow_nil: true

        attr_reader :project_number

        def initialize(project_number:, new_project_name:, new_project_description:, options: {})
          super(options: options)

          raise ArgumentError, 'project_number is blank' if project_number.blank?
          raise ArgumentError, 'new_project_name is blank' if new_project_name.blank?

          @project_number = project_number

          @project = Models::Project.find_by_number(project_number: project_number)

          @new_project = Models::Project.new(project_name: new_project_name.strip,
            description: new_project_description&.strip, options: options).tap(&:validate)
        end

        def respond(response:)
          return false unless response
          return false if new_project.invalid?

          project.rename!(new_project_name: new_project_name, new_project_description: new_project_description)
        end

        def project_does_not_exist?
          return true unless project.present?

          !project.exist?
        end

        def new_project_already_exists?
          new_project.exist?
        end

        def new_project_name
          new_project.project_name
        end

        def new_project_description
          new_project.description
        end

        def new_project_errors
          new_project.errors.full_messages
        end

        private

        attr_reader :new_project, :project
      end
    end
  end
end
