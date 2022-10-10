# frozen_string_literal: true

module Dsu
  module Support
    module Say
      class << self
        def say(text, color = nil)
          unless color.is_a? Symbol
            raise ':color is the wrong type. "Symbol" was expected, but ' \
                  "\"#{color}\" was returned."
          end

          puts text.public_send(color)
        end
      end

      def say(text, color = nil)
        Say.say(text, color)
      end
    end
  end
end
