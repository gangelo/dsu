# frozen_string_literal: true

RSpec.shared_examples 'the description is correct' do
  it 'sets the description attribute correctly' do
    expect(edited_entry.description).to eq expected_description
  end
end

RSpec.describe Dsu::Models::EditedEntry do
  subject(:edited_entry) { described_class.new(editor_line: editor_line) }

  let(:editor_line) { 'This is a description' }

  describe '#initialize' do
    context 'when editor_line is nil' do
      let(:editor_line) { nil }
      let(:expected_error) { /editor_line is not a string/ }

      it_behaves_like 'an error is raised'
    end

    context 'when editor_line is blank' do
      let(:editor_line) { '' }
      let(:expected_error) { /editor_line is not editable/ }

      it_behaves_like 'an error is raised'
    end

    context 'when editor_line is a ruby comment' do
      let(:editor_line) { '  # This is a comment' }
      let(:expected_error) { /editor_line is not editable/ }

      it_behaves_like 'an error is raised'
    end

    context 'when editor_line is not a string' do
      let(:editor_line) { :not_a_string }
      let(:expected_error) { /editor_line is not a string/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe 'validation' do
    context 'when editor_line is between 2 and 256 characters' do
      let(:editor_line) { 'This is a description' }

      it_behaves_like 'the validation passes'
    end

    context 'when editor_line is < 2 characters' do
      let(:editor_line) { 'X' }
      let(:expected_errors) do
        [
          /is too short/
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when editor_line is > 256 characters' do
      let(:editor_line) { 'X' * 257 }
      let(:expected_errors) do
        [
          /is too long/
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end

  describe '#description' do
    context 'when the description does not need to be cleaned up' do
      let(:editor_line) { expected_description }
      let(:expected_description) { 'This is a description' }

      it_behaves_like 'the description is correct'
    end

    context 'when the description not needs to be cleaned up' do
      let(:editor_line) do
        '     This      is      a         description    '
      end
      let(:expected_description) { 'This is a description' }

      it_behaves_like 'the description is correct'
    end
  end
end
