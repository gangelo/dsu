# frozen_string_literal: true

module Dsu
  module Support
    module HashKeyComparable
      module_function

      def compare_keys(expected_hash:, hash:)
        hash_keys = hash.keys.sort
        expected_hash_keys = expected_hash.keys.sort

        return true if hash_keys == expected_hash_keys

        missing_keys = expected_hash_keys - hash_keys
        extra_keys = hash_keys - expected_hash_keys

        yield(expected_keys, missing_keys, extra_keys) if block_given?

        false
      end
    end
  end
end
