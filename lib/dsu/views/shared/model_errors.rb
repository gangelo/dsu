# frozen_string_literal: true

require_relative 'messages'

module Dsu
  module Views
    module Shared
      class ModelErrors
        def initialize(model:, options: {})
          raise ArgumentError, 'model is nil' if model.nil?
          raise ArgumentError, "model is the wrong object type: \"#{model}\"" unless model.is_a?(ActiveModel::Model)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

          @model = model
          @options = options || {}
          @header = options[:header] || 'The following ERRORS were encountered; changes could not be saved:'
        end

        def render
          return if model.valid?

          messages = model.errors.full_messages
          Messages.new(messages: messages, message_type: :error, options: { header: header }).render
        end

        private

        attr_reader :model, :header, :options
      end
    end
  end
end
