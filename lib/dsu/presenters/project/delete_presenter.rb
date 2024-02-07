# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class DeletePresenter < BasePresenterEx
        attr_reader :project_name

        delegate :description, to: :project, prefix: true, allow_nil: true

        def initialize(project_name:, options: {})
          super(options: options)

          raise ArgumentError, 'project_name is blank' if project_name.blank?

          self.project_name = project_name
        end

        def respond(response:)
          return false unless response
          return false if project_does_not_exist? || project_default?

          project.delete! if project&.present?
        end

        def project_does_not_exist?
          !project.exist?
        end

        def project_default?
          project.default_project?
        end

        def project_errors
          return false unless project.persisted?

          project.errors.full_messages
        end

        private

        attr_writer :project_name

        def project
          @project ||= Models::Project.find_or_initialize(project_name: project_name)
        end
      end
    end
  end
end
