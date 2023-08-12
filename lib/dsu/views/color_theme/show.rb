# frozen_string_literal: true

require_relative '../../models/color_theme'
require_relative '../../models/configuration'
require_relative '../entry_group/show'
require_relative '../shared/error'
require_relative '../shared/info'
require_relative '../shared/success'
require_relative '../shared/warning'

module Dsu
  module Views
    module ColorTheme
      class Show
        include Support::ColorThemable

        def initialize(theme_name:, options: {})
          @theme_name = theme_name
          @options = options || {}
        end

        def render
          render!
        end

        private

        attr_reader :theme_name, :options

        def color_theme
          @color_theme ||= Models::ColorTheme.find_or_initialize(theme_name: theme_name)
        end

        def presenter
          @presenter ||= Dsu::Presenters::ColorThemeShowPresenter.new(color_theme, options: options)
        end

        def render!
          puts presenter.header
          puts

          presenter.detail
          puts

          display_entry_group_example
          puts

          display_configuration_example
          puts

          display_messages_example
          puts

          puts presenter.footer
        end

        def display_entry_group_example
          puts apply_theme('`dsu list` example', theme_color: color_theme.subheader)
          puts

          options = custom_options
          entry_group = mock_entry_group(options)
          EntryGroup::Show.new(entry_group: entry_group, options: options).render
        end

        def display_configuration_example
          puts apply_theme('`dsu config info` example', theme_color: color_theme.subheader)
          puts

          Views::Configuration::Show.new(config: Models::Configuration.new(options: custom_options)).render
        end

        def display_messages_example
          options = custom_options
          messages = ['Example 1', 'Example 2', 'Example 3']

          puts apply_theme('Message examples', theme_color: color_theme.subheader)
          puts

          Shared::Error.new(messages: messages, header: 'Errors example', options: options).render
          puts

          Shared::Info.new(messages: messages, header: 'Info example', options: options).render
          puts

          Shared::Success.new(messages: messages, header: 'Success example', options: options).render
          puts

          Shared::Warning.new(messages: messages, header: 'Warning example', options: options).render
        end

        def mock_entry_group(options)
          @mock_entry_group ||= Dsu::Models::EntryGroup.new(time: Time.now, entries: [
            Dsu::Models::Entry.new(description: 'Dsu entry 1', options: options),
            Dsu::Models::Entry.new(description: 'Dsu entry 2', options: options),
            Dsu::Models::Entry.new(description: 'Dsu entry 3', options: options)
          ], options: options)
        end

        def custom_options
          options.merge(theme_name: color_theme.theme_name, output_stream: $stdout)
        end
      end
    end
  end
end
