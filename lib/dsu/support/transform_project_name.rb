# frozen_string_literal: true

module Dsu
  module Support
    module TransformProjectName
      TRANSFORM_PROJECT_NAME_REGEX = %r{[^/\w\s]|_}
      TRANSFORM_PROJECT_NAME_SEPARATOR = '-'

      module_function

      def transform_project_name(project_name, options: {})
        normalized_name = project_name
          .gsub(TRANSFORM_PROJECT_NAME_REGEX, ' ')   # Replace non-word characters and underscores with space
          .strip                                     # Remove leading and trailing spaces
          .squeeze(' ')                              # Convert consecutive spaces to a single space
          .tr(' ', TRANSFORM_PROJECT_NAME_SEPARATOR) # Replace spaces with hyphens
          .squeeze(TRANSFORM_PROJECT_NAME_SEPARATOR) # Ensure no consecutive hyphens

        normalized_name.downcase! if options[:downcase]
        normalized_name
      end
    end
  end
end
