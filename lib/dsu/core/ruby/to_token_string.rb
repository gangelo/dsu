# frozen_string_literal: true

class Array
  class << self
    TOKEN_STRING_JOIN_TOKEN = ', '
  end

  def to_token_string(quote: true)
    return map(&:to_s).join(TOKEN_STRING_JOIN_TOKEN) unless quote

    map { |element| "\"#{element}\""}.join(TOKEN_STRING_JOIN_TOKEN)
  end
end
