# frozen_string_literal: true

require 'thor'

module Dsu
  module Support
    module Ask
      def ask(prompt)
        options = {}
        Thor::LineEditor.readline(prompt, options)
      end

      def yes?(prompt, options: {})
        auto_prompt = auto_prompt(prompt, options)
        return auto_prompt unless auto_prompt.nil?

        Thor::Base.shell.new.yes?(prompt)
      end

      private

      def auto_prompt(prompt, options)
        @auto_prompt ||= begin
          value = options.dig('prompts', prompt)
          value = (value == 'true' unless value.nil?)
          value
        end
      end
    end
  end
end
