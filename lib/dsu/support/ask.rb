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

        unless auto_prompt.nil?
          puts prompt
          return auto_prompt
        end

        Thor::Base.shell.new.yes?(prompt)
      end

      private

      def auto_prompt(prompt, options)
        options = options.with_indifferent_access
        prompt = Utils.strip_escapes(prompt)
        @auto_prompt ||= begin
          value = options.dig(:prompts, prompt) || options.dig(:prompts, :any)
          value = (value == 'true' unless value.nil?)
          value
        end
      end
    end
  end
end
