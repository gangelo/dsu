# frozen_string_literal: true

require 'json'
require 'active_support/core_ext/module/delegation'
require_relative '../models/entry_group'
require_relative '../support/entry_group_fileable'

module Dsu
  module Services
    class EntryGroupWriterService
      include Dsu::Support::EntryGroupFileable

      delegate :time, to: :entry_group

      def initialize(entry_group:, options: {})
        raise ArgumentError, 'entry_group is nil' if entry_group.nil?
        raise ArgumentError, 'entry_group is the wrong object type' unless entry_group.is_a?(Dsu::Models::EntryGroup)
        raise ArgumentError, 'options is nil' if options.nil?
        raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

        @entry_group = entry_group
        @options = options || {}
      end

      def call
        entry_group.validate!
        create_entry_group_path_if!
        write_entry_group_to_file!
      rescue ActiveModel::ValidationError
        puts "Error(s) encountered: #{entry_group.errors.full_messages}"
        raise
      end

      private

      attr_reader :entry_group, :options

      def write_entry_group_to_file!
        create_entry_group_path_if!
        File.write(entry_group_file_path, JSON.pretty_generate(entry_group.to_h))
        puts "Wrote group entry file: #{entry_group_file_path}" if ENV['ENV_DEV']
      end
    end
  end
end
