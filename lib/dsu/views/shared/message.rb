# frozen_string_literal: true

require_relative '../../models/color_theme'

module Dsu
  module Views
    module Shared
      class Message
        include Support::ColorThemable

        MESSAGE_TYPES = %i[error info success warning].freeze

        def initialize(messages:, message_type:, options: {})
          messages = [messages] unless messages.is_a?(Array)
          messages = messages.select(&:present?)

          validate_arguments!(messages, message_type, options)

          @messages = messages
          @message_type = message_type
          @options = options || {}
          @message_color = color_theme.public_send(message_type)
          @header = options[:header]
          @ordered_list = options.fetch(:ordered_list, true)
        end

        def render
          return if messages.empty?

          output_stream.puts apply_theme(header, theme_color: color_theme.header) if header.present?

          if messages.one?
            output_stream.puts apply_theme(messages[0], theme_color: message_color)
            return
          end

          messages.each_with_index do |message, index|
            message = "#{index + 1}. #{message}" if ordered_list?
            output_stream.puts apply_theme(message, theme_color: message_color)
          end
        end

        private

        attr_reader :messages, :message_color, :message_type, :header, :options

        def color_theme
          @color_theme ||= begin
            theme_name = options.fetch(:theme_name, Models::Configuration.new.theme_name)
            Models::ColorTheme.find(theme_name: theme_name)
          end
        end

        def ordered_list?
          @ordered_list
        end

        def output_stream
          @output_stream ||= options.fetch(:output_stream, $stdout)
        end

        def validate_arguments!(messages, message_type, options)
          raise ArgumentError, 'messages is empty' if messages.empty?
          unless Models::ColorTheme::DEFAULT_THEME_COLORS.key?(message_type)
            raise ArgumentError, 'message_type is not a valid message type'
          end
          raise ArgumentError, 'options is nil' if options.nil?

          %i[\[\] fetch].each do |method|
            next if options.respond_to?(method)

            raise ArgumentError, "options does not respond to :#{method}"
          end
        end
      end
    end
  end
end
