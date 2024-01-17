# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class UsePresenter < BasePresenterEx
        def initialize(project_name_or_number:, options: {})
          super(options: options)

          @project_name_or_number = project_name_or_number
        end

        def respond(response:)
          return false unless response

          project.use!
        end

        def project
          @project ||= if project_name?
            Dsu::Models::Project.find(project_name: project_name)
          elsif project_number?
            Dsu::Models::Project.find_by_number(project_number: project_number)
          elsif project_default?
            Dsu::Models::Project.default_project
          end
        end

        def project_does_not_exist?
          !project.exist?
        end

        def project_errors?
          project.invalid?
        end

        private

        attr_reader :options, :project_name_or_number

        def project_name?
          !(project_number? || project_default?)
        end

        def project_number?
          project_name_or_number =~ /\A\d+\z/
        end

        def project_default?
          project_name_or_number.blank?
        end

        def project_name
          return unless project_name?

          project_name_or_number
        end

        def project_number
          return -1 unless project_number?

          project_name_or_number.to_i
        end
      end
    end
  end
end
