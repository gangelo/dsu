# frozen_string_literal: true

require 'thor'

module Dsu
  module Support
    module Ask
      ASK_YES = %w[y yes].freeze
      # ASK_NO = %w[n no].freeze
      # ASK_CANCEL = %w[c cancel].freeze
      # ASK_YES_NO_CANCEL = ASK_YES.concat(ASK_NO).concat(ASK_CANCEL).freeze

      def ask(prompt)
        options = {}
        Thor::LineEditor.readline(prompt, options)
      end

      def yes?(prompt, color = nil)
        Thor::Base.shell.new.yes?(prompt, color)
      end

      # def no?(prompt)
      #   ask_with(prompt: prompt, values: ASK_NO)
      # end

      # def yes_no_cancel(prompt)
      #   ask_with(prompt: prompt, values: ASK_YES_NO_CANCEL)
      # end

      # private

      # def ask_with(prompt:, values:)
      #   p "#{prompt}"
      #   values.include? STDIN.gets.chomp
      # end
    end
  end
end
