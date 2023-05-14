# frozen_string_literal: true

require 'active_model'
require_relative '../support/edited_entry_line'

module Dsu
  module Models
    class EditedEntry
      include ActiveModel::Model

      # Check a single editor command token.
      ENTRY_CMD_REGEX = /\A([+-]|a(?:dd)?|d(?:elete)?\z)/i
      # Checks for a single uuid token.
      ENTRY_UUID_REGEX = /\A(\h{8})\z/i
      # Checks for a description within the editor line that may or may not
      # include an editor command or uuid.
      ENTRY_DESCRIPTION_REGEX = /\A(?:(?<uuid>\h{8})\s|(?<cmd>[+\-]|a|add|d|delete)\s)?(?<description>.*)\z/i

      validate :validate_uuid_or_cmd_present, unless: proc { |e| e.uuid? || e.cmd? }
      validates :description, presence: true, length: { minimum: 2, maximum: 256 }

      attr_reader :editor_line, :cmd, :description, :uuid

      # Expects a string from the editor
      def initialize(editor_line)
        raise ArgumentError, 'editor_line is not a string' unless editor_line.is_a?(String) || editor_line.blank?

        # Append a space to the end of the editor line to make regex matching
        # match into the proper groups.
        @editor_line = editor_line&.strip&.gsub(/\s+/, ' ').try(:<<, ' ')

        match = ENTRY_DESCRIPTION_REGEX.match(@editor_line)
        @cmd = match.try(:[], :cmd)
        @uuid = match.try(:[], :uuid)
        @description = match.try(:[], :description)&.strip
        # Just making things consistent since uuid and cmd are nil if not present.
        @description = nil if @description.blank?
      end

      def cmd?
        cmd.present?
      end

      def uuid?
        uuid.present?
      end

      def description?
        description.present?
      end

      class << self
        def edited_entry_from(editor_line)
          # TODO: Return true/false
        end

        def edited_entry?(editor_line)

        end

        def edited_entry_line_info(editor_line)
          Support::EntryGroupEditorLine.new(editor_line)
        end
      end

      private

      def validate_uuid_or_cmd_present
        return if uuid? || cmd?

        errors.add(:uuid, 'or cmd must be present.')
      end
    end
  end
end
