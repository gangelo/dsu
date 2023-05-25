# frozen_string_literal: true

require 'net/http'
require 'json'

module Dsu
  module Services
    module AI
      # SERVICE_URI = URI('https://api.openai.com/v1/chat/completions').freeze

      # class TenseTranslatorService
      #   def initialize(entries:, options: {})
      #     @entries = entries
      #     @options = options.merge({ tense: :past })
      #   end

      #   def call
      #     request = Net::HTTP::Post.new(SERVICE_URI.path)
      #     request['Content-Type'] = 'application/json'
      #     request['Authorization'] = "Bearer #{configuration[:ai_api_key]}"

      #     request.body = request_body

      #     response = http.request(request)
      #     JSON.parse(response.body)
      #   end

      #   private

      #   attr_reader :entries, :options

      #   def http
      #     Net::HTTP.new(SERVICE_URI.host, SERVICE_URI.port).tap do |http|
      #       http.use_ssl = true
      #     end
      #   end

      #   def request_body
      #     {
      #       messages: [
      #         {
      #           role: 'system',
      #           content: 'You are a helpful assistant.'
      #         },
      #         {
      #           role: 'user',
      #           content: message
      #         }
      #       ]
      #     }.to_json
      #   end

      #   def instructions
      #     @instructions ||= "Please translate the following sentences into the past #{options[:tense]}:\n\n"
      #   end

      #   def message
      #     @message ||= "#{instructions}\n\n#{entries.map(&:description).join("\n")}"
      #   end
      # end
    end
  end
end
