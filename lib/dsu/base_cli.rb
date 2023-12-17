# frozen_string_literal: true

require 'bundler'
require 'thor'
require_relative 'command_services/add_entry_service'
require_relative 'models/color_theme'
require_relative 'models/configuration'
require_relative 'models/entry_group'
require_relative 'services/stdout_redirector_service'
require_relative 'support/color_themable'
require_relative 'support/command_help_colorizeable'
require_relative 'support/command_hookable'
require_relative 'support/entry_group_viewable'
require_relative 'support/times_sortable'
require_relative 'version'
require_relative 'views/entry_group/show'

module Dsu
  class BaseCLI < ::Thor
    include Support::ColorThemable
    include Support::CommandHelpColorizable
    include Support::CommandHookable
    include Support::EntryGroupViewable
    include Support::TimesSortable

    class_option :debug, type: :boolean, default: false

    default_command :help

    def initialize(*args)
      super

      @configuration = Models::Configuration.new
    end

    class << self
      def exit_on_failure?
        false
      end

      def date_option_description
        I18n.t('options.date_option_description')
      end

      def mnemonic_option_description
        I18n.t('options.mnemonic_option_description')
      end
    end

    private

    attr_reader :configuration

    def color_theme
      Models::ColorTheme.current_or_default
    end
  end
end
