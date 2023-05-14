# frozen_string_literal: true

require_relative '../models/entry'

module Dsu
  module Support
    class EditedEntryLine
      ENTRY_REGEX = /(\S+)\s(.+)/

      attr_reader :cmd, :sha, :line, :description

      def initialize(line)
        raise ArgumentError, 'line is nil' if line.nil?

        @line = line.strip.gsub(/\s+/, ' ')

        match_data = @line.match(ENTRY_REGEX)

        sha_or_cmd = match_data.try(:[], 1)
        @sha = sha_or_cmd if sha_or_cmd&.match?(Models::Entry::ENTRY_UUID_REGEX)
        @cmd = sha_or_cmd unless comment? || sha_or_cmd&.match?(Models::Entry::ENTRY_UUID_REGEX)

        @description = match_data.try(:[], 2)
      end

      def skip?
        delete? || (!add? && !sha?)
      end

      def comment?
        line[0] == '#'
      end

      def blank?
        line.blank?
      end

      def sha?
        sha.present?
      end

      def cmd?
        cmd.present?
      end

      def delete?
        %w[- d delete].include?(cmd)
      end

      def add?
        %w[+ a add].include?(cmd)
      end

      def sha_or_editor_cmd
        sha || cmd
      end
    end
  end
end
