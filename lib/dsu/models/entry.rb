# frozen_string_literal: true

require 'deco_lite'
require 'securerandom'

module Dsu
  module Models
    class Entry < DecoLite::Model
      validates :uuid, presence: true, format: {
        with: /\A[0-9a-f]{8}\z/i,
        message: 'is the wrong format. ' \
                 '0-9, a-f, and 8 characters were expected.' \
      }
      validates :description, presence: true, length: { minimum: 2, maximum: 80 }
      validates :long_description, length: { minimum: 2, maximum: 256 }, allow_nil: true

      def initialize(description:, uuid: nil, long_description: nil)
        raise ArgumentError, 'description is nil' if description.nil?
        raise ArgumentError, 'description is the wrong object type' unless description.is_a?(String)
        raise ArgumentError, 'uuid is the wrong object type' unless uuid.is_a?(String) || uuid.nil?
        raise ArgumentError, 'long_description is the wrong object type' unless long_description.is_a?(String) || long_description.nil?

        uuid ||= SecureRandom.uuid[0..7]

        super(hash: {
          uuid: uuid,
          description: description,
          long_description: long_description
        })
      end

      def required_fields
        %i[uuid description]
      end

      def long_description?
        long_description.present?
      end

      def ==(other)
        return false unless other.is_a?(Entry)

        uuid == other.uuid &&
          description == other.description &&
          long_description == other.long_description
      end
    end
  end
end
