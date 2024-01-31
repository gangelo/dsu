# frozen_string_literal: true

RSpec.describe Dsu::Views::ImportDates do
  subject(:import_view) { described_class.new(presenter: presenter, options: options) }

  let(:options) { {} }
  let(:import_file_path) { 'spec/fixtures/files/import.csv' }
  let(:from) { Time.parse('2023-12-31').localtime }
  let(:to) { Time.parse('2024-01-02').localtime }

  let(:presenter) do
    Dsu::Presenters::Import::DatesPresenter.new(from: from, to: to, import_file_path: import_file_path, options: options)
  end

  describe '#initialize' do
    it 'does not raise an error' do
      expect { import_view }.to_not raise_error
    end
  end

  describe '#render' do
    it_behaves_like 'the import file does not exist'
    it_behaves_like 'there is nothing to import'
    it_behaves_like 'there is something to import'
    it_behaves_like 'the import raises an error'
    it_behaves_like 'the import has errors'
  end
end
