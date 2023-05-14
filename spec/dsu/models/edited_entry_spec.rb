# frozen_string_literal: true

RSpec.shared_examples 'the uuid is correct' do
  it 'sets the uuid attribute correctly' do
    expect(edited_entry.uuid).to eq expected_uuid
  end
end

RSpec.shared_examples 'the cmd is correct' do
  it 'sets the cmd attribute correctly' do
    expect(edited_entry.cmd).to eq expected_cmd
  end
end

RSpec.shared_examples 'the description is correct' do
  it 'sets the description attribute correctly' do
    expect(edited_entry.description).to eq expected_description
  end
end

RSpec.describe Dsu::Models::EditedEntry do
  subject(:edited_entry) { described_class.new(editor_line) }

  let(:editor_line) { '012345 This is a description' }

  describe '#initialize' do
    context 'when editor_line is nil' do
      let(:editor_line) { nil }

      it_behaves_like 'no error is raised'
    end

    context 'when editor_line is not a blank' do
      let(:editor_line) { '' }

      it_behaves_like 'no error is raised'
    end

    context 'when editor_line is not a string' do
      let(:editor_line) { :not_a_string }
      let(:expected_error) { /editor_line is not a string/ }

      it_behaves_like 'an error is raised'
    end

    context 'when editor_line has an incorrect format' do
      let(:editor_line) { '0123' }

      it_behaves_like 'no error is raised'
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

      context "when 'A <description>'" do
        let(:editor_line) { 'A This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'ADD <description>'" do
        let(:editor_line) { 'ADD This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'D <description>'" do
        let(:editor_line) { 'D This is a description' }

        it_behaves_like 'the validation passes'
      end

      context "when 'DELETE <description>'" do
        let(:editor_line) { 'DELETE This is a description' }

        it_behaves_like 'the validation passes'
      end
    end

    context 'when editor_line is not the correct format' do
      context "when '<no uuid or command> <description>'" do
        let(:editor_line) { 'This is a description' }
        let(:expected_errors) do
          [
            'Uuid or cmd must be present.'
          ]
        end

        it_behaves_like 'the validation fails'
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

      context "when there is no description '<uuid> <no descripton>'" do
        let(:editor_line) { '01234567' }
        let(:expected_errors) do
          [
            "Description can't be blank",
            'Description is too short (minimum is 2 characters)'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end
  end

  describe '#uuid' do
    context 'when there is a uuid' do
      let(:editor_line) { "#{expected_uuid} This is a description" }
      let(:expected_uuid) { '01234567' }

      it_behaves_like 'the uuid is correct'
    end

    context 'when there is no uuid' do
      let(:editor_line) { 'This is a description' }
      let(:expected_uuid) { nil }

      it_behaves_like 'the uuid is correct'
    end
  end

  describe '#description' do
    context 'when there is a description' do
      let(:editor_line) { "0a2b4c6d #{expected_description}" }
      let(:expected_description) { 'This is a description' }

      it_behaves_like 'the description is correct'
    end

    context 'when there is no description' do
      let(:editor_line) { '0f2e4d6c' }
      let(:expected_description) { nil }

      it_behaves_like 'the description is correct'
    end
  end

  describe '#cmd' do
    context 'when there is a cmd' do
      let(:editor_line) { "#{expected_cmd} This is a description" }
      let(:expected_cmd) { 'add' }

      it_behaves_like 'the cmd is correct'
    end

    context 'when there is no description' do
      let(:editor_line) { 'This is a description' }
      let(:expected_cmd) { nil }

      it_behaves_like 'the cmd is correct'
    end
  end

  describe '#uuid?' do
    context 'when there is a uuid' do
      let(:editor_line) { '12345678 This is a description' }

      it 'returns true' do
        expect(edited_entry.uuid?).to be(true)
      end
    end

    context 'when there is no uuid' do
      let(:editor_line) { 'This is a description' }

      it 'returns false' do
        expect(edited_entry.uuid?).to be(false)
      end
    end
  end

  describe '#description?' do
    context 'when there is a description' do
      let(:editor_line) { 'delete This is a description' }

      it 'returns true' do
        expect(edited_entry.description?).to be(true)
      end
    end

    context 'when there is no description' do
      let(:editor_line) { '+' }

      it 'returns false' do
        expect(edited_entry.description?).to be(false)
      end
    end
  end

  describe '#cmd?' do
    context 'when there is a cmd' do
      let(:editor_line) { '+ This is a description' }

      it 'returns true' do
        expect(edited_entry.cmd?).to be(true)
      end
    end

    context 'when there is no cmd' do
      let(:editor_line) { 'This is a description' }

      it 'returns false' do
        expect(edited_entry.cmd?).to be(false)
      end
    end
  end
end
