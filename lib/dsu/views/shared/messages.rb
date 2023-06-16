# frozen_string_literal: true

require_relative '../../models/color_theme'

module Dsu
  module Views
    module Shared
      class Messages
        include Support::ColorThemable

        MESSAGE_TYPES = %i[error info success warning].freeze

        def initialize(messages:, message_type:, options: {})
          messages = [messages] unless messages.is_a?(Array)

          validate_arguments!(messages, message_type, options)

          @messages = messages.select(&:present?)
          @message_type = message_type
          @message_color = color_theme.public_send(message_type)
          @options = options || {}
          @header = options[:header]
        end

        def render
          return if messages.empty?

          puts apply_color_theme(header, color_theme_color: color_theme.header) if header.present?

          if messages.one?
            puts apply_color_theme(messages[0], color_theme_color: message_color)
            return
          end

          messages.each_with_index do |message, index|
            message = "#{index + 1}. #{message}"
            puts apply_color_theme(message, color_theme_color: message_color)
          end
        end

        private

        attr_reader :messages, :message_color, :message_type, :header, :options

        def color_theme
          @color_theme ||= Models::ColorTheme.current_or_default
        end

        def validate_arguments!(messages, message_type, options)
          raise ArgumentError, 'messages is nil' if messages.nil?
          raise ArgumentError, 'messages is the wrong object type' unless messages.is_a?(Array)
          raise ArgumentError, 'messages elements are the wrong object type' unless messages.all?(String)
          raise ArgumentError, 'message_type is nil' if message_type.nil?
          raise ArgumentError, 'message_type is the wrong object type' unless message_type.is_a?(Symbol)

          unless Models::ColorTheme::DEFAULT_THEME_COLORS.key?(message_type)
            raise ArgumentError,
              'message_type is not a valid message type'
          end
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)
        end
      end
    end
  end
end
