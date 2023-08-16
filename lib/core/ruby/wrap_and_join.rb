# frozen_string_literal: true

module WrapAndJoin
  class << self
    def included(base)
      base.const_set(:WRAP_AND_JOIN_JOIN_TOKEN, ', ')
    end
  end

  def wrap_and_join(wrapper: %w["], join: Array::WRAP_AND_JOIN_JOIN_TOKEN)
    validate_wrapper!(wrapper)
    validate_join!(join)

    wrapper << wrapper.first if wrapper.count == 1
    map { |element| "#{wrapper[0]}#{element}#{wrapper[1]}" }.join(join)
  end

  private

  def validate_wrapper!(wrapper)
    raise ArgumentError, 'wrapper is nil' if wrapper.nil?
    raise ArgumentError, 'wrapper must be an Array' unless wrapper.is_a?(Array)
    raise ArgumentError, 'wrapper must be an Array of 1 or 2 wrapper elements' unless wrapper.count.between?(1, 2)
  end

  def validate_join!(join)
    return if join.nil?

    raise ArgumentError, 'join must be a String' unless join.is_a?(String)
  end
end
