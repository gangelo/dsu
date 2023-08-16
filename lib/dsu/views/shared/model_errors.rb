# frozen_string_literal: true

require_relative 'error'

module Dsu
  module Views
    module Shared
      class ModelErrors < Error
        def initialize(model:, options: {})
          raise ArgumentError, 'model is nil' if model.nil?
          raise ArgumentError, "model is the wrong object type: \"#{model}\"" unless model.is_a?(ActiveModel::Model)

          header = options[:header] || 'The following ERRORS were encountered; changes could not be saved:'
          super(messages: model.errors.full_messages, header: header, options: options)

          @model = model
        end

        def render
          return if model.valid?

          super
        end

        private

        attr_reader :model
      end
    end
  end
end
