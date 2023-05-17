# frozen_string_literal: true

require 'active_model'
require 'securerandom'
require_relative '../support/descriptable'
require_relative '../validators/description_validator'

module Dsu
  module Models
    class Entry
      include ActiveModel::Model
      include Support::Descriptable

      validates_with Validators::DescriptionValidator, fields: [:description]

      attr_reader :description

      def initialize(description:)
        raise ArgumentError, 'description is nil' if description.nil?
        raise ArgumentError, 'description is the wrong object type' unless description.is_a?(String)
        raise ArgumentError, 'description is blank' if description.blank?

        @description = description.strip
      end

      def to_h
        { description: description }
      end

      def ==(other)
        return false unless other.is_a?(Entry)

        description == other.description
      end
    end
  end
end
