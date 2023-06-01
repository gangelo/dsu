# frozen_string_literal: true

require_relative '../../support/colorable'
require_relative '../../support/say'

module Dsu
  module Views
    module Shared
      class Messages
        include Support::Colorable
        include Support::Say

        MESSAGE_TYPES = %i[error info success warning].freeze

        def initialize(messages:, message_type:, options: {})
          messages = [messages] unless messages.is_a?(Array)

          validate_arguments!(messages, message_type, options)

          @messages = messages.select(&:present?)
          @message_type = message_type
          # We've inluded Support::Colorable, so simply upcase the message_type
          # and convert it to a symbol; this will equate to the color we want.
          @message_color = self.class.const_get(message_type.to_s.upcase)
          @options = options || {}
          @header = options[:header]
        end

        def render
          return if messages.empty?

          say header, message_color if header.present?

          if messages.one?
            say(messages[0], message_color)
            return
          end

          messages.each_with_index do |message, index|
            say "#{index + 1}. #{message}", message_color
          end
        end

        private

        attr_reader :messages, :message_color, :message_type, :header, :options

        def validate_arguments!(messages, message_type, options)
          raise ArgumentError, 'messages is nil' if messages.nil?
          raise ArgumentError, 'messages is the wrong object type' unless messages.is_a?(Array)
          raise ArgumentError, 'messages elements are the wrong object type' unless messages.all?(String)
          raise ArgumentError, 'message_type is nil' if message_type.nil?
          raise ArgumentError, 'message_type is the wrong object type' unless message_type.is_a?(Symbol)
          raise ArgumentError, 'message_type is not a valid message type' unless MESSAGE_TYPES.include?(message_type)
          raise ArgumentError, 'options is nil' if options.nil?
          raise ArgumentError, 'options is the wrong object type' unless options.is_a?(Hash)
        end
      end
    end
  end
end
