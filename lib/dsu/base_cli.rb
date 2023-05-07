# frozen_string_literal: true

require 'bundler'
require 'thor'
require_relative 'command_services/add_entry_service'
require_relative 'models/entry_group'
require_relative 'services/configuration_loader_service'
require_relative 'services/entry_group_hydrator_service'
require_relative 'services/entry_group_reader_service'
require_relative 'support/colorable'
require_relative 'support/configuration'
require_relative 'support/entry_group_viewable'
require_relative 'support/times_sortable'
require_relative 'version'
require_relative 'views/entry_group/show'

module Dsu
  #
  # The `dsu` command.
  #
  class BaseCLI < ::Thor
    include Support::Colorable
    include Support::EntryGroupViewable
    include Support::TimesSortable

    class_option :debug, type: :boolean, default: false

    default_command :help

    class << self
      def exit_on_failure?
        false
      end

      def date_option_description
        <<-DATE_OPTION_DESC
          Where DATE may be any date string that can be parsed using `Time.parse`. Consequently, you may use also use '/' as date separators, as well as omit thee year if the date you want to display is the current year (e.g. <month>/<day>, or 1/31). For example: `require 'time'; Time.parse('2023-01-02'); Time.parse('1/2') # etc.`
        DATE_OPTION_DESC
      end
    end

    def initialize(*args)
      super

      @configuration = Services::ConfigurationLoaderService.new.call
    end

    private

    attr_reader :configuration

    def sorted_dsu_times_for(times:)
      times_sort(times: times_for(times: times), entries_display_order: entries_display_order)
    end

    def entries_display_order
      @entries_display_order ||= configuration[:entries_display_order]
    end
  end
end
