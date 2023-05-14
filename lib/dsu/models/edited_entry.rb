# frozen_string_literal: true

require 'active_model'
require_relative '../support/edited_entry_line'

module Dsu
  module Models
    class EditedEntry
      include ActiveModel::Model

      ENTRY_CMD_TOKEN_REGEX = /\A([+-]|a(?:dd)?|d(?:elete)?\z)/i
      ENTRY_CMD_REGEX = /\A([+-]|a(?:dd)?|d(?:elete)?)\s+.*\z/i

      ENTRY_UUID_TOKEN_REGEX = /\A(\h{8})\z/i
      ENTRY_UUID_REGEX = /\A(\h{8})\s+.*\z/i

      ENTRY_DESCRIPTION_REGEX = /\A(?:(?:\b|[+-]|a(?:dd)?|d(?:elete)?)\b)?(.*)\z/i

      validate :validate_uuid, if: :uuid?
      validate :validate_cmd, if: :cmd?
      validate :validate_uuid_or_cmd_present, unless: proc { |e| e.uuid? || e.cmd? }
      validates :description, presence: true, length: { minimum: 2, maximum: 256 }

      attr_reader :editor_line, :cmd, :description, :uuid

      # Expects a string from the editor
      def initialize(editor_line)
        raise ArgumentError, 'editor_line is not a string' unless editor_line.is_a?(String) || editor_line.blank?

        @editor_line = editor_line&.strip&.gsub(/\s+/, ' ')
        @uuid = ENTRY_UUID_REGEX.match(@editor_line).try(:[], 1)
        @cmd = ENTRY_CMD_REGEX.match(@editor_line).try(:[], 1)
        @description = ENTRY_DESCRIPTION_REGEX.match(@editor_line).try(:[], 1)
      end

      def required_fields
        %i[]
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

      def validate_uuid
        return if ENTRY_UUID_TOKEN_REGEX.match?(uuid)

        #errors.add(:uuid, "can't be blank.") and return if uuid.blank?

        errors.add(:uuid, 'is the wrong format. ' \
                          '0-9, a-f, and 8 characters were expected.')
      end

      def validate_cmd
        return if ENTRY_CMD_TOKEN_REGEX.match?(cmd)

        #errors.add(:cmd, "can't be blank.") and return if cmd.blank?

        errors.add(:cmd, 'is an invalid command. ' \
                         '+, a, add, -, d or delete were expected.')
      end
    end
  end
end
