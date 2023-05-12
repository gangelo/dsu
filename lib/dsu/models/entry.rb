# frozen_string_literal: true

require 'deco_lite'
require 'securerandom'
require_relative '../support/descriptable'

module Dsu
  module Models
    class Entry < DecoLite::Model
      include Support::Descriptable

      ENTRY_UUID_REGEX = /\A[0-9a-f]{8}\z/i

      validates :uuid, presence: true, format: {
        with: ENTRY_UUID_REGEX,
        message: 'is the wrong format. ' \
                 '0-9, a-f, and 8 characters were expected.' \
      }
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
    end
  end
end
