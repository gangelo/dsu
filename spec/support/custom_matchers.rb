# frozen_string_literal: true

RSpec::Matchers.define :validate_with_validator do |validator_class|
  match do |model|
    return validates_with?(model, validator_class) unless on_attribute?

    model.class.validators_on(attribute).any?(validator_class)
  end

  chain :on do |attribute_name|
    self.attribute = attribute_name
  end

  description do
    "validate attribute #{attribute} with #{validator_class}"
  end

  failure_message do |model|
    return "expected #{model.class} to validate attribute #{attribute} with #{validator_class}" if on_attribute?

    "expected #{model.class} to validate with #{validator_class}"
  end

  failure_message_when_negated do |model|
    "expected #{model.class} to not validate attribute #{attribute} with #{validator_class}" if on_attribute?

    "expected #{model.class} to not validate with #{validator_class}"
  end

  private

  attr_accessor :attribute

  def on_attribute?
    attribute.present?
  end

  def validates_with?(model, validator_class)
    model._validators[attribute].find { |validator| validator.is_a?(validator_class) } || false
  end
end
