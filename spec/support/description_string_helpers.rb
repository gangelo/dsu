# frozen_string_literal: true

module DescriptionStringHelpers
  def description_having(max_length: Dsu::Support::ShortString::SHORT_STRING_MAX_COUNT)
    num_words = Dsu::Support::ShortString::SHORT_STRING_MAX_COUNT
    FFaker::Lorem.words(num_words).join(' ')[0...max_length].tap do |desc|
      desc[-1] = 'x' if desc[-1] == ' '
    end
  end
end
