# frozen_string_literal: true

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
    end
  end
end
