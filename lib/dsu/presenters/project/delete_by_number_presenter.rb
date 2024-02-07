# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class DeleteByNumberPresenter < BasePresenterEx
        attr_reader :project_number

        delegate :project_name, to: :project, allow_nil: true
        delegate :description, to: :project, prefix: true, allow_nil: true

        def initialize(project_number:, options: {})
          super(options: options)

          raise ArgumentError, 'project_number is blank' if project_number.blank?

          self.project_number = project_number
        end

        def respond(response:)
          return false unless response
          return false if project_does_not_exist? || project_default?

          project.delete! if project&.present?
        end

        def project_does_not_exist?
          !project&.exist?
        end

        def project_default?
          project&.default_project?
        end

        def project_errors
          return false unless project&.persisted?

          project.errors.full_messages
        end

        private

        attr_writer :project_number

        def project
          @project ||= Models::Project.find_by_number(project_number: project_number)
        end
      end
    end
  end
end
