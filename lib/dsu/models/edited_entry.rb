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
        raise ArgumentError, 'editor_line is not a string' unless editor_line.is_a?(String)

        editor_line = self.class.clean_editor_line(editor_line: editor_line)
        raise ArgumentError, 'editor_line is not editable' unless self.class.editable?(editor_line: editor_line)

        @description = editor_line
      end

      class << self
        def editable?(editor_line:)
          editor_line = clean_editor_line(editor_line: editor_line)
          !(editor_line.blank? || editor_line[0] == '#')
        end

        def clean_editor_line(editor_line:)
          return if editor_line.nil?

          editor_line.strip.gsub(/\s+/, ' ')
        end
      end

      def to_entry!
        validate!
        Entry.new(description: description)
      end
    end
  end
end
