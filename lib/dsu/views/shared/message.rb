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

          validate_arguments!(messages, message_type, options)

          @messages = messages.select(&:present?)
          @message_type = message_type
          @message_color = color_theme.public_send(message_type)
          @options = options || {}
          @header = options[:header]
          @ordered_list = options.fetch(:ordered_list, true)
        end

        def render
          return if messages.empty?

          output_stream.puts apply_color_theme(header, color_theme_color: color_theme.header) if header.present?

          if messages.one?
            output_stream.puts apply_color_theme(messages[0], color_theme_color: message_color)
            return
          end

          messages.each_with_index do |message, index|
            message = "#{index + 1}. #{message}" if ordered_list?
            output_stream.puts apply_color_theme(message, color_theme_color: message_color)
          end
        end

        private

        attr_reader :messages, :message_color, :message_type, :header, :options

        def color_theme
          @color_theme ||= Models::ColorTheme.current_or_default
        end

        def ordered_list?
          @ordered_list
        end

        def output_stream
          raise NotImplementedError, 'output_stream must be implemented'
        end

        def validate_arguments!(messages, message_type, options)
          validate_messages!(messages)
          validate_message_type!(message_type)
          validate_options!(options)
        end

        def validate_messages!(messages)
          raise ArgumentError, 'messages is nil' if messages.nil?
          raise ArgumentError, 'messages is the wrong object type' unless messages.is_a?(Array)
          raise ArgumentError, 'messages elements are the wrong object type' unless messages.all?(String)
        end

        def validate_message_type!(message_type)
          raise ArgumentError, 'message_type is nil' if message_type.nil?
          raise ArgumentError, 'message_type is the wrong object type' unless message_type.is_a?(Symbol)
          unless Models::ColorTheme::DEFAULT_THEME_COLORS.key?(message_type)
            raise ArgumentError, 'message_type is not a valid message type'
          end
        end

        def validate_options!(options)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)

          header = options[:header]
          return if header.nil? || header.is_a?(String)

          raise ArgumentError, "header is the wrong object type: \"#{header}\""
        end
      end
    end
  end
end
