# frozen_string_literal: true

require 'bundler'
require 'thor'
require_relative 'command_services/add_entry_service'
require_relative 'models/color_theme'
require_relative 'models/configuration'
require_relative 'models/entry_group'
require_relative 'support/color_themable'
require_relative 'support/command_hookable'
require_relative 'support/entry_group_viewable'
require_relative 'support/times_sortable'
require_relative 'version'
require_relative 'views/entry_group/show'

module Dsu
  class BaseCLI < ::Thor
    include Support::ColorThemable
    include Support::CommandHookable
    include Support::EntryGroupViewable
    include Support::TimesSortable

    class_option :debug, type: :boolean, default: false

    default_command :help

    class << self
      def exit_on_failure?
        false
      end

      def date_option_description
        <<-OPTION_DESC
          DATE
          \x5
          This may be any date string that can be parsed using `Time.parse`. Consequently, you may use also use '/' as date separators, as well as omit thee year if the date you want to display is the current year (e.g. <month>/<day>, or 1/31). For example: `require 'time'; Time.parse('01/02/2023'); Time.parse('1/2') # etc.`
        OPTION_DESC
      end

      def mneumonic_option_description
        <<-OPTION_DESC
          MNEUMONIC
          \x5
          This may be any of the following: n|today|t|tomorrow|y|yesterday|+n|-n.

          \x5
          Where n, t, y are aliases for today, tomorrow, and yesterday, respectively.

          \x5
          Where +n, -n are relative date mneumonics (RDNs). Generally speaking, RDNs are relative to the current date. For example, a RDN of +1 would be equal to `Time.now + 1.day` (tomorrow), and a RDN of -1 would be equal to `Time.now - 1.day` (yesterday).

          \x5
          In some cases the behavior RDNs have on some commands are context dependent; in such cases the behavior will be noted.
        OPTION_DESC
      end
    end

    def initialize(*args)
      super

      @configuration = Models::Configuration.current_or_default
    end

    private

    attr_reader :configuration

    def sorted_dsu_times_for(times:)
      times_sort(times: times_for(times: times), entries_display_order: entries_display_order)
    end

    def entries_display_order
      @entries_display_order ||= configuration.entries_display_order
    end

    def color_theme
      Models::ColorTheme.current_or_default
    end
  end
end
