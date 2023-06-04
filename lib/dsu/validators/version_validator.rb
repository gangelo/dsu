# frozen_string_literal: true

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class VersionValidator < ActiveModel::Validator
      def validate(record)
        version = record.version

        unless version.is_a?(String)
          record.errors.add(:version, 'is the wrong object type. ' \
                                      "\"String\" was expected, but \"#{version.class}\" was received.")
          return
        end

        if version.blank?
          record.errors.add(:version, :blank)
          return
        end

        unless version.match?(Dsu::VERSION_REGEX)
          record.errors.add(:version, 'must match the format "#.#.#[.alpha.#]" where # is 0-n')
          return
        end

        unless version == record.class::VERSION
          record.errors.add(:version, "\"#{version}\" is not the correct version: \"#{record.class::VERSION}\"")
        end
      end
    end
  end
end
