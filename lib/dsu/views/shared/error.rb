# frozen_string_literal: true

require_relative 'message'

module Dsu
  module Views
    module Shared
      class Error < Message
        def initialize(messages:, header: nil, options: {})
          options = { header: header, output_stream: $stderr }.merge(options)

          super(messages: messages, message_type: :error, options: options)
        end
      end
    end
  end
end
