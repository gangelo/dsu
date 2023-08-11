# frozen_string_literal: true

require_relative 'message'

module Dsu
  module Views
    module Shared
      class Error < Message
        def initialize(messages:, header: nil, options: {})
          options = options.merge(header: header, output_stream: $stderr)

          super(messages: messages, message_type: :error, options: options)
        end
      end
    end
  end
end
