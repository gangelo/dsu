# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class CreatePresenter < BasePresenterEx
        attr_reader :project

        def initialize(project_name:, description:, options: {})
          super(options: options)

          @project = Models::Project.new(project_name: project_name, description: description, options: options)
        end

        def render(response:)
          return false unless response

          project.create!
        end

        def project_already_exists?
          project.exist?
        end

        def project_errors?
          project.invalid?
        end

        private

        attr_reader :options
      end
    end
  end
end
