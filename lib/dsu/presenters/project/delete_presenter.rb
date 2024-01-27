# frozen_string_literal: true

require_relative '../../models/project'
require_relative '../base_presenter_ex'

module Dsu
  module Presenters
    module Project
      class DeletePresenter < BasePresenterEx
        attr_writer :project_name_or_number

        def initialize(project_name_or_number:, options: {})
          super(options: options)

          @project_name_or_number = project_name_or_number
        end

        def respond(response:)
          return false unless response

          project.delete! if project&.present?
        end

        def project_name
          project.project_name
        end

        def project_name_or_number
          return project_name if delete_by_project_name?
          return project_number if delete_by_project_number?

          Models::Project.default_project_name
        end

        def project_description
          return unless project&.present?

          project.description
        end

        def project_does_not_exist?
          !project&.exist?
        end

        def project_errors
          return [] unless project_errors?

          project.errors.full_messages
        end

        def delete_by_project_name?
          !delete_by_project_number? && !delete_by_project_default?
        end

        def delete_by_project_number?
          /\A\d+\z/.match?(@project_name_or_number.to_s)
        end

        def delete_by_project_default?
          @project_name_or_number.blank?
        end

        private

        attr_reader :options

        def project
          return @project if defined?(@project)

          @project = if delete_by_project_name? && Dsu::Models::Project.project_initialized?(project_name: project_name)
            Dsu::Models::Project.find(project_name: project_name)
          elsif delete_by_project_number?
            Dsu::Models::Project.find_by_number(project_number: project_number)
          elsif delete_by_project_default?
            Dsu::Models::Project.default_project
          end
        end

        def project_errors?
          project&.invalid?
        end

        # def project_name
        #   return unless delete_by_project_name?

        #   @project_name_or_number
        # end

        def project_number
          return -1 unless delete_by_project_number?

          @project_name_or_number.to_i
        end
      end
    end
  end
end
