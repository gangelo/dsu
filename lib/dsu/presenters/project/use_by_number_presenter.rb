# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'
require_relative 'defaultable'

module Dsu
  module Presenters
    module Project
      class UseByNumberPresenter < BasePresenterEx
        include Defaultable

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

          project.default! if make_default? && project&.present?
          project.use! if project&.present?
        end

        def already_current_project?
          project&.current_project?
        end

        def project_does_not_exist?
          !project&.exist?
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
