# frozen_string_literal: true

require 'active_model'
require_relative '../support/descriptable'
require_relative '../support/presentable'
require_relative '../validators/description_validator'
require_relative '../validators/version_validator'

module Dsu
  module Models
    # This class represents something someone might want to share at their
    # daily standup (DSU).
    class Entry
      include ActiveModel::Model
      include Support::Descriptable
      include Support::Presentable

      VERSION = 0

      validates_with Validators::VersionValidator
      validates_with Validators::DescriptionValidator

      attr_reader :description
      attr_accessor :version

      def initialize(description:, version: nil)
        raise ArgumentError, 'description is the wrong object type' unless description.is_a?(String)
        raise ArgumentError, 'version is the wrong object type' unless version.is_a?(Integer) || version.nil?

        # Make sure to call the setter method so that the description is cleaned up.
        self.description = description
        @version = version || VERSION
      end

      class << self
        def clean_description(description)
          return if description.nil?

          description.strip.gsub(/\s+/, ' ')
        end
      end

      def description=(description)
        @description = self.class.clean_description description
      end

      def to_h
        {
          version: version,
          description: description
        }
      end

      # Override == and hash so that we can compare Entry objects based
      # on description alone. This is useful for comparing entries in
      # an array, for example.
      def ==(other)
        return false unless other.is_a?(Entry)

        version == other.version &&
          description == other.description
      end
      alias eql? ==

      def hash
        [
          version,
          description
        ].hash
      end
    end
  end
end
