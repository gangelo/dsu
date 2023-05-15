# frozen_string_literal: true

require 'active_model'
require_relative '../support/descriptable'
require_relative '../validators/description_validator'

module Dsu
  module Models
    class EditedEntry
      include ActiveModel::Model
      include Support::Descriptable

      validates_with Validators::DescriptionValidator, fields: [:description]

      attr_reader :description

      # Expects a string from the editor
      def initialize(editor_line:)
        #require 'pry-byebug'; binding.pry
        raise ArgumentError, 'editor_line is not a string' unless editor_line.is_a?(String)
        raise ArgumentError, 'editor_line is blank' if editor_line.blank?

        @editor_line = editor_line
        @description = clean_edititor_line_for_description(@editor_line)
      end

      class << self
        def editable?(editor_line:)
          !(editor_line.blank? || editor_line[0] == '#')
        end
      end

      def to_entry!
        validate!
        Entry.new(description: description)
      end

      private

      attr_reader :editor_line

      def clean_edititor_line_for_description(editor_line)
        editor_line.strip.gsub(/\s+/, ' ')
      end
    end
  end
end
