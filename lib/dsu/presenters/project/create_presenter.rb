# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class CreatePresenter < BasePresenterEx
        delegate :project_name, to: :project

        def initialize(project_name:, description:, options: {})
          super(options: options)

          @project = Models::Project.new(project_name: project_name, description: description, options: options)
        end

        def respond(response:)
          return false unless response

          project.create!
        end

        def project_already_exists?
          project.exist?
        end

        def project_errors?
          project.invalid?
        end

        def project_errors
          return [] unless project_errors?

          project.errors.full_messages
        end

        private

        attr_reader :project, :options
      end
    end
  end
end
