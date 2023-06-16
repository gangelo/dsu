# frozen_string_literal: true

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class VersionValidator < ActiveModel::Validator
      def validate(record)
        version = record.version

        if version.nil?
          record.errors.add(:version, 'is nil')
          return
        end

        unless version.is_a?(Integer)
          record.errors.add(:version, 'is the wrong object type. ' \
                                      "\"Integer\" was expected, but \"#{version.class}\" was received.")
          nil
        end

        # TODO: This validation should check the configuration version
        # against the current migration version and they should match.
        # unless version == record.class::VERSION
        #   record.errors.add(:version, "\"#{version}\" is not the correct version: \"#{record.class::VERSION}\"")
        # end
      end
    end
  end
end
