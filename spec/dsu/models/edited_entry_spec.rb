# frozen_string_literal: true

RSpec.describe Dsu::Models::EditedEntry do
  subject(:edited_entry) { described_class.new(editor_line) }

  let(:editor_line) { '012345 This is a description' }

  describe '#initialize' do
    context 'when editor_line is nil' do
      let(:editor_line) { nil }

      it_behaves_like 'no error is raised during initialization'
    end

    context 'when editor_line is not a blank' do
      let(:editor_line) { '' }

      it_behaves_like 'no error is raised during initialization'
    end

    context 'when editor_line is not a string' do
      let(:editor_line) { :not_a_string }
      let(:expected_error) { /editor_line is not a string/ }

      it_behaves_like 'an error is raised during initialization'
    end

    context 'when editor_line has an incorrect format' do
      let(:editor_line) { '0123' }

      it_behaves_like 'no error is raised during initialization'
    end
  end

  describe 'validation' do
    context 'when editor_line is the correct format' do
      context "when it contains '<uuid> <description>'" do
        let(:editor_line) { '01234567 This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when '+ <description>'" do
        let(:editor_line) { '+ This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'a <description>'" do
        let(:editor_line) { 'a This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'add <description>'" do
        let(:editor_line) { 'add This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when '- <description>'" do
        let(:editor_line) { '- This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'd <description>'" do
        let(:editor_line) { 'd This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'delete <description>'" do
        let(:editor_line) { 'delete This is a description' }

        it_behaves_like 'the validation passes'
      end
    end

    context 'when editor_line is not the wrong format' do
      context "when '<no uuid or command> <description>'" do
        let(:editor_line) { 'This is a description' }
        let(:expected_errors) do
          [
            'Uuid or cmd must be present.'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    context "when the editor command is not delimited by a word boundry '<editor command><description>'" do
      context "when '+<description>'" do
        let(:editor_line) { '+This is a description' }
        let(:expected_errors) { ['Uuid or cmd must be present.'] }

        it_behaves_like 'the validation fails'
      end

      context "when 'a<description>'" do
        let(:editor_line) { 'aThis is a description' }
        let(:expected_errors) { ['Uuid or cmd must be present.'] }

        it_behaves_like 'the validation fails'
      end

      context "when 'add<description>'" do
        let(:editor_line) { 'addThis is a description' }
        let(:expected_errors) { ['Uuid or cmd must be present.'] }

        it_behaves_like 'the validation fails'
      end

      context "when '-<description>'" do
        let(:editor_line) { '-This is a description' }
        let(:expected_errors) { ['Uuid or cmd must be present.'] }

        it_behaves_like 'the validation fails'
      end

      context "when 'd<description>'" do
        let(:editor_line) { 'dThis is a description' }
        let(:expected_errors) { ['Uuid or cmd must be present.'] }

        it_behaves_like 'the validation fails'
      end

      context "when 'delete<description>'" do
        let(:editor_line) { 'deleteThis is a description' }
        let(:expected_errors) { ['Uuid or cmd must be present.'] }

        it_behaves_like 'the validation fails'
      end
    end
  end
end
