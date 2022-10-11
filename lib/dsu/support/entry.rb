# frozen_string_literal: true

require 'deco_lite'
require_relative 'entries_version'
require_relative 'validate_time'

module Dsu
  module Support
    class Entry < DecoLite::Model
      include EntriesVersion
      include ValidateTime

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

      def initialize(description:, long_description: nil, time: nil, order: nil, version: nil)
        time ||= Time.now.utc

        unless time.is_a? Time
          raise ':time is the wrong object type. ' \
                "\"Time\" was expected, but \"#{time.class}\" was received."
        end

        time = time.utc unless time.utc?

        hash = {
          order: order,
          time: time,
          description: description,
          long_description: long_description,
          version: version || ENTRIES_VERSION
        }
        super(hash: hash)
      end

      def required_fields
        %i[order time description version]
      end

      def ==(other)
        to_h == other.to_h
      end

      def to_h_localized
        hash = to_h
        hash.merge({ time: hash[:time].localtime })
      end
    end
  end
end
