# frozen_string_literal: true

require 'json'
require 'active_support/core_ext/module/delegation'
require_relative '../support/entry_group_fileable'

module Dsu
  module Services
    class EntryGroupWriterService
      include Dsu::Support::EntryGroupFileable

      delegate :time, to: :entry_group

      def initialize(entry_group:, options: {})
        # TODO: Check entry_group is a hash?
        # TODO: Or accept a hash OR an EntryGroup object?
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
