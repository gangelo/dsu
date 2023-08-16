# frozen_string_literal: true

module Dsu
  module Services
    # This service captures $stderr, resirects it to a StringIO object,
    # and returns the string value.
    # https://stackoverflow.com/questions/4459330/how-do-i-temporarily-redirect-stderr-in-ruby/4459463#4459463
    module StderrRedirectorService
      class << self
        def call
          raise ArgumentError, 'no block was provided' unless block_given?

          # The output stream must be an IO-like object. In this case we capture it in
          # an in-memory IO object so we can return the string value. Any IO object can
          # be used here.
          string_io = StringIO.new
          original_stderr, $stderr = $stderr, string_io # rubocop:disable Style/ParallelAssignment
          yield
          string_io.string
        ensure
          # Restore the original $stderr.
          $stderr = original_stderr
        end
      end
    end
  end
end
