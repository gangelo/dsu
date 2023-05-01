# frozen_string_literal: true

require 'deco_lite'
require 'securerandom'
require_relative 'entries_version'
require_relative 'validate_time'

module Dsu
  module Support
    class Entry < DecoLite::Model
      include EntriesVersion
      include ValidateTime

      validates :uuid, presence: true, format: {
        with: /\A[0-9a-f]{8}\z/i,
        message: 'is the wrong format. ' \
                 '0-9, a-f, and 8 characters were expected.' \
      }
      validates :description, presence: true, length: { minimum: 2, maximum: 80 }
      validates :long_description, length: { minimum: 2, maximum: 256 }, allow_nil: true
      validates :order, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
      validates :version, presence: true,
        format: {
          with: ENTRIES_VERSION_REGEXP,
          message: 'is the wrong format. ' \
                   "/#{ENTRIES_VERSION_REGEXP.source}/ " \
                   'format was expected, but the version format did not match.'
        }

      def initialize(description:, uuid: nil, long_description: nil, time: nil, order: nil, version: nil)
        uuid ||= SecureRandom.uuid[0..7]
        time ||= Time.now.utc

        unless time.is_a? Time
          raise ':time is the wrong object type. ' \
                "\"Time\" was expected, but \"#{time.class}\" was received."
        end

        time = time.utc unless time.utc?

        hash = {
          uuid: uuid,
          order: order,
          time: time,
          description: description,
          long_description: long_description,
          version: version || ENTRIES_VERSION
        }
        super(hash: hash)
      end

      def required_fields
        %i[uuid order time description version]
      end

      def ==(other)
        return false unless other.respond_to?(:to_h)

        to_h == other.to_h
      end

      def to_h
        hash = super
        hash[:time] = Time.parse(hash[:time]) unless hash[:time].is_a? Time
        hash
      end

      def to_h_localized
        hash = to_h
        hash[:time] = hash[:time].localtime
        hash
      end
    end
  end
end
