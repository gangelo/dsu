# frozen_string_literal: true

require 'colorized_string'

module Dsu
  module Support
    module Say
      class << self
        def say(text, color = nil)
          puts say_string_for(text, color)
        end

        def say_string_for(text, color = nil)
          unless color.nil? || color.is_a?(Symbol)
            raise ':color is the wrong type. "Symbol" was expected, but ' \
                  "\"#{color.class}\" was returned."
          end

          return text if color.nil?

          text.public_send(color)
        end
      end

      def say(text, color = nil)
        Say.say(text, color)
      end

      # NOTE: some modes (ColorizedString.modes) will cancel out each other if
      # overriden in a block. For example, if you set a string to be bold
      # (i.e. mode: :bold) and then override it in a block (e.g. string.underline)
      # the string will not be bold and underlined, it will just be underlined.
      def colorize_string(string:, color: :default, mode: :default)
        colorized_string = ColorizedString[string].colorize(color: color, mode: mode)
        colorized_string = yield colorized_string if block_given?
        colorized_string
      end
    end
  end
end
