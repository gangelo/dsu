# frozen_string_literal: true

require_relative 'messages'

module Dsu
  module Views
    module Shared
      class GenericErrors
        def initialize(errors:, header: nil, options: {})
          validate_arguments!(errors, header, options)

          errors = [errors] unless errors.is_a?(Array)
          @errors = errors
          @options = options || {}
          @header = header || 'The following ERRORS were encountered:'
        end

        def render
          Messages.new(messages: errors, message_type: :error, options: { header: header }).render
        end

        private

        attr_reader :errors, :header, :options

        def validate_arguments!(errors, header, options)
          raise ArgumentError, 'errors is nil' if errors.nil?
          unless errors.is_a?(String) || errors.is_a?(Array)
            raise ArgumentError, "errors is the wrong object type: \"#{errors}\""
          end
          unless header.nil? || header.is_a?(String)
            raise ArgumentError, "header is the wrong object type: \"#{header}\""
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)
        end
      end
    end
  end
end
