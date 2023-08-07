# frozen_string_literal: true

require_relative 'message'

module Dsu
  module Views
    module Shared
      class Error < Message
        def initialize(messages:, header: nil, options: {})
          super(messages: messages, message_type: :error, options: { header: header }.merge(options))
        end

        def output_stream
          @output_stream ||= $stderr
        end
      end
    end
  end
end
