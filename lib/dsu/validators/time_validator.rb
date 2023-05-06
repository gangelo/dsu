# frozen_string_literal: true

# https://guides.rubyonrails.org/active_record_validations.html#validates-with
module Dsu
  module Validators
    class TimeValidator < ActiveModel::Validator
      def validate(record)
        raise 'options[:fields] is not defined.' unless options.key? :fields
        raise 'options[:fields] is not an Array.' unless options[:fields].is_a? Array
        raise 'options[:fields] elements are not Symbols.' unless options[:fields].all?(Symbol)

        options[:fields].each do |field|
          time = record.send(field)

          if time.nil?
            record.errors.add(field, :blank)
            next
          end

          unless time.is_a?(Time)
            record.errors.add(field, 'is the wrong object type. ' \
                                     "\"Time\" was expected, but \"#{time.class}\" was received.")
            next
          end

          if time.utc?
            record.errors.add(field, 'is not in localtime format.')
            next
          end
        end
      end
    end
  end
end
