# frozen_string_literal: true

require_relative '../support/field_errors'

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    # TODO: I18n.
    class ProjectNameValidator < ActiveModel::Validator
      include Support::FieldErrors

      def validate(record)
        unless record.project_name.is_a?(String)
          record.errors.add(:project_name, 'is the wrong object type. ' \
                                           "\"String\" was expected, but \"#{record.project.class}\" was received.")
          return
        end

        unless record.project_name.present?
          record.errors.add(:project_name, :blank, '')

          return
        end

        validate_project_name record
      end

      private

      def validate_project_name(record)
        project_name = record.project_name

        return if project_name.length.between?(min_project_name_length(record), max_project_name_length(record))

        if project_name.length < min_project_name_length(record)
          # TODO: I18n.
          record.errors.add(:project_name, "is too short: \"#{record.project_name}\" " \
                                           "(minimum is #{min_project_name_length(record)} characters).")
        elsif project_name.length > max_project_name_length(record)
          # TODO: I18n.
          record.errors.add(:project_name, "is too long: \"#{record.project_name}\" " \
                                           "(maximum is #{max_project_name_length(record)} characters).")
        end
      end

      def min_project_name_length(record)
        record.class::MIN_PROJECT_NAME_LENGTH
      end

      def max_project_name_length(record)
        record.class::MAX_PROJECT_NAME_LENGTH
      end
    end
  end
end
