# frozen_string_literal: true

RSpec.describe Dsu::Support::Say do
  let(:text) { 'This is a test' }
  let(:color) { nil }

  describe 'class methods' do
    describe '.say' do
      subject(:say) { described_class.say text, color }

      context 'when argument :color is nil' do
        it 'puts the text to stdout' do
          expect { subject }.to output("#{text}\n").to_stdout
        end
      end
    end

    describe '.say_string_for' do
      subject(:say) { described_class.say_string_for text, color }

      context 'when argument :color is nil' do
        it 'returns the text unaltered' do
          expect(subject).to eq text
        end
      end

      context 'when argument :color is not a Symbol' do
        let(:color) { 1 }
        let(:expected_error) do
          ':color is the wrong type. "Symbol" was expected, but ' \
                  "\"Integer\" was returned."
        end

        it_behaves_like 'an error is raised'
      end

      context 'when argument :color is a valid color' do
        let(:color) { :magenta }
        let(:expected_text) { /.+#{text}.+/ }

        it 'puts the text to stdout' do
          expect(subject).to include(expected_text).once
        end
      end
    end
  end
end
