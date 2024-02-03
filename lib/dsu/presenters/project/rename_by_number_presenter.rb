# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class RenameByNumberPresenter < BasePresenterEx
        attr_reader :project_number, :description

        # delegate :project_name, to: :project, allow_nil: true
        # delegate :description, to: :project, prefix: true, allow_nil: true

        def initialize(project_number:, description:, options: {})
          super(options: options)

          raise ArgumentError, 'project_number is blank' if project_number.blank?

          self.project_number = project_number
          self.description = description
        end

        def respond(response:)
          return false unless response

          project.rename(project_name: :project_name, description: description) if project_already_exists?
        end

        def project_already_exists?
          project.exist?
        end

        def project_errors
          return false unless project&.persisted?

          project.errors.full_messages
        end

        private

        attr_writer :project_number, :description

        def project
          @project ||= Models::Project.find_by_number(project_number: project_number)
        end
      end
    end
  end
end
