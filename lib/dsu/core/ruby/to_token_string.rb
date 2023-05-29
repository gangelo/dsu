# frozen_string_literal: true

class Array
  TOKEN_STRING_JOIN_TOKEN = ', '

  def to_token_string(quote: true)
    return map(&:to_s).join(TOKEN_STRING_JOIN_TOKEN) unless quote

    map { |element| "\"#{element}\""}.join(TOKEN_STRING_JOIN_TOKEN)
  end
end
