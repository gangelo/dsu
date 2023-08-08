# frozen_string_literal: true

RSpec.describe Dsu::Views::Shared::Message do
  subject(:message) do
    described_class.new(messages: messages, message_type: message_type, options: options)
  end

  let(:messages) { 'Test message' }
  let(:message_type) { :success }
  let(:options) { {} }

  describe '.new' do
    it 'returns a new instance of the class' do
      expect(message).to be_a(described_class)
    end
  end

  describe '#render' do
    context 'when #output_stream is not overridden' do
      it 'raises an error' do
        expect { message.render }.to raise_error(NotImplementedError)
      end
    end

    context 'when #output_stream is overridden' do
      subject(:message) do
        Class.new(described_class) do
          def output_stream
            $stdout
          end
        end.new(messages: messages, message_type: message_type, options: options)
      end

      context 'with an invalid message type' do
        let(:message_type) { :invalid }

        it 'raises an error' do
          expect { message.render }.to raise_error('message_type is not a valid message type')
        end
      end

      context 'with invalid option type' do
        let(:options) { 1 }

        it 'raises an error' do
          expect { message.render }.to raise_error(/options does not respond to/)
        end
      end

      context 'when there are no messages' do
        let(:messages) { [] }

        it 'renders nothing to the console' do
          expect { message.render }.to raise_error(/messages is empty/)
        end
      end

      context 'with empty messages' do
        let(:messages) { [nil, nil] }

        it 'raises an error' do
          expect { message.render }.to raise_error(/messages is empty/)
        end
      end

      context 'when there is only one message' do
        let(:output) do
          Dsu::Services::StdoutRedirectorService.call do
            message.render
          end
        end

        it 'renders the message to the console' do
          expect(strip_escapes(output).strip).to eq(messages)
        end
      end

      context 'when there are multiple messages' do
        let(:messages) do
          [
            'Test message 1',
            'Test message 2'
          ]
        end
        let(:output) do
          Dsu::Services::StdoutRedirectorService.call do
            message.render
          end
        end
        let(:expected_output) do
          messages.each_with_index.map do |message, index|
            "#{index + 1}. #{message}"
          end
        end

        it 'renders the message to the console' do
          expect(strip_escapes(output).strip).to eq(expected_output.join("\n"))
        end
      end
    end
  end
end
