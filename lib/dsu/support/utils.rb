# frozen_string_literal: true

module Dsu
  module Utils
    class << self
      def strip_escapes(escaped_string)
        escaped_string.gsub(/\e\[[0-9;]*[a-zA-Z]/, '')
      end
    end
  end
end
