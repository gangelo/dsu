# frozen_string_literal: true

module Dsu
  module Support
    module CommandOptions
      module TimeMnemonics
        # TODO: I18n.
        TODAY = %w[n today].freeze
        TOMORROW = %w[t tomorrow].freeze
        YESERDAY = %w[y yesterday].freeze

        RELATIVE_REGEX = /[+-]\d+/
      end
    end
  end
end
