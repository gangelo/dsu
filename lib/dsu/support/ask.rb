# frozen_string_literal: true

require 'thor'

module Dsu
  module Support
    module Ask
      ASK_YES = %w[y yes].freeze

      def ask(prompt)
        options = {}
        Thor::LineEditor.readline(prompt, options)
      end

      def yes?(prompt, color = nil)
        Thor::Base.shell.new.yes?(prompt, color)
      end
    end
  end
end
