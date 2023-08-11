# frozen_string_literal: true

require_relative 'message'

module Dsu
  module Views
    module Shared
      class Info < Message
        def initialize(messages:, header: nil, options: {})
          options = options.merge(header: header)

          super(messages: messages, message_type: :info, options: options)
        end
      end
    end
  end
end
