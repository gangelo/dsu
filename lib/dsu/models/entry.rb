# frozen_string_literal: true

require 'deco_lite'
require 'securerandom'
require_relative '../support/descriptable'

module Dsu
  module Models
    class Entry < DecoLite::Model
      include Support::Descriptable

      ENTRY_UUID_REGEX = /\A(\h{8})\s+/i

      validate :validate_uuid
      validates :description, presence: true, length: { minimum: 2, maximum: 256 }

      def initialize(description:, uuid: nil)
        raise ArgumentError, 'description is nil' if description.nil?
        raise ArgumentError, 'description is the wrong object type' unless description.is_a?(String)
        raise ArgumentError, 'uuid is the wrong object type' unless uuid.is_a?(String) || uuid.nil?

        uuid ||= SecureRandom.uuid[0..7]

        super(hash: {
          uuid: uuid,
          description: description
        })
      end

      def required_fields
        %i[uuid description]
      end

      def ==(other)
        return false unless other.is_a?(Entry)

        uuid == other.uuid && description == other.description
      end

      private

      def validate_uuid
        return if uuid.match?(ENTRY_UUID_REGEX)

        errors.add(:uuid, "can't be blank.") and return if uuid.blank?

        errors.add(:uuid, 'is the wrong format. ' \
                          '0-9, a-f, and 8 characters were expected.')
      end
    end
  end
end
