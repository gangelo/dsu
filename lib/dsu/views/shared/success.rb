# frozen_string_literal: true

require_relative 'message'

module Dsu
  module Views
    module Shared
      class Success < Message
        def initialize(messages:, header: nil, options: {})
          options = { header: header, output_stream: $stdout }.merge(options)

          super(messages: messages, message_type: :success, options: options)
        end
      end
    end
  end
end
