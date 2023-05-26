# frozen_string_literal: true

RSpec.describe Dsu::Validators::EntriesValidator do
  subject(:entries_validator) do
    Class.new do
      include ActiveModel::Model

      class << self
        def name
          'Test'
        end
      end

      attr_accessor :entries

      def initialize(entries:)
        @entries = entries
      end

      validates_with Dsu::Validators::EntriesValidator
    end.new(entries: entries)
  end

  context 'when the entries are valid' do
    let(:entries) { build_list(:entry, 2) }

    it_behaves_like 'the validation passes'
  end

  context 'when the entries are invalid' do
    context 'when entries is not an Array' do
      let(:entries) { 'invalid' }
      let(:expected_errors) do
        [
          /Entries is the wrong object type/
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when an entry is not an Entry object' do
      let(:entries) do
        [
          build(:entry),
          :not_an_entry,
          build(:entry)
        ]
      end
      let(:expected_errors) do
        [
          /Entries Array element is the wrong object type/
        ]
      end

      it_behaves_like 'the validation fails'
    end

    context 'when an entry is not unique' do
      let(:entries) do
        [
          build(:entry, description: 'Duplicate descriptionXXXXYYYYY'),
          build(:entry),
          build(:entry, description: 'Duplicate descriptionXXXXYYYYY'),
          build(:entry)
        ]
      end
      let(:expected_errors) do
        [
          'Entries Array contains a duplicate entry: "Duplicate...".'
        ]
      end

      it 'uses the short description in the error message' do
        entries_validator.validate
        expect(entries_validator.errors.full_messages).to eq(expected_errors)
      end

      it_behaves_like 'the validation fails'
    end

    context 'when an entry fails validation' do
      let(:entries) do
        [
          build(:entry),
          build(:entry, :invalid),
          build(:entry)
        ]
      end
      let(:expected_errors) do
        [
          "Entries entry Description can't be blank"
        ]
      end

      it_behaves_like 'the validation fails'
    end
  end
end
