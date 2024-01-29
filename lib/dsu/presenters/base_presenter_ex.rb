# frozen_string_literal: true

module Dsu
  module Presenters
    class BasePresenterEx
      def initialize(options: {})
        @options = options&.dup || {}
      end

      private

      attr_reader :options
    end
  end
end
