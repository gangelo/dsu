# frozen_string_literal: true

def json_to_hash_for(file_path)
  JSON.parse(Dsu::Crud::RawJsonFile.read!(file_path: file_path), symbolize_names: true)
end

RSpec.describe Dsu::Crud::JsonFile do
  subject(:json_file) do
    Class.new do
      include ActiveModel::Model
      include Dsu::Crud::JsonFile

      class << self
        def name
          'Klass'
        end
      end

      attr_accessor :file_data, :file_path, :options

      validates :file_data, presence: true

      def initialize(file_path:, file_data:, options:)
        @file_path = file_path
        @file_data = file_data
        @options = options
      end

      def to_h
        @file_data.dup
      end
    end.new(file_path: file_path, file_data: file_data, options: options)
  end

  before do
    File.delete(temp_file)
  end

  let(:input_file) { 'spec/fixtures/files/json_file.json' }
  let(:file_path) { temp_file.path }
  let(:file_data) { nil }
  let(:options) { {} }
  let(:with_existing_file_path) do
    raise "The fixture file (#{input_file}) does not exist" unless File.exist?(input_file)

    file_hash = JSON.parse(File.read(input_file))
    File.write(temp_file, JSON.pretty_generate(file_hash))
  end

  describe '#exist?' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      specify 'the file exists before it is checked' do
        expect(File.exist?(file_path)).to be true
      end

      it 'returns true' do
        expect(json_file.exist?).to be(true)
      end
    end

    context 'when the file does not exist' do
      specify 'the file does not exist before it is checked' do
        expect(File.exist?(file_path)).to be false
      end

      it 'returns false' do
        expect(json_file.exist?).to be(false)
      end
    end
  end

  describe '#delete' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      specify 'the file exists before the delete' do
        expect(File.exist?(file_path)).to be true
      end

      it 'returns true if it deletes the file' do
        expect(json_file.delete).to be(true)
      end

      it 'delete the file' do
        json_file.delete
        expect(json_file.exist?).to be(false)
      end
    end

    context 'when the file does not exist' do
      specify 'the file does not exist before the delete!' do
        expect(File.exist?(file_path)).to be false
      end

      it 'raises an error if the file does not exist' do
        expect { json_file.delete! }.to raise_error(/does not exist/)
      end
    end
  end

  describe '#delete!' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      specify 'the file exists before the delete' do
        expect(File.exist?(file_path)).to be true
      end

      it 'returns true if it deletes the file' do
        expect(json_file.delete).to be(true)
      end

      it 'delete the file' do
        json_file.delete
        expect(json_file.exist?).to be(false)
      end
    end
  end

  describe '#read' do
    before do
      with_existing_file_path
    end

    let(:expected_hash) do
      {
        json_key: 'json_value'
      }
    end

    it 'returns the file_hash representation of the file' do
      expect(json_file.read).to eq(expected_hash)
    end
  end

  describe '#read!' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      let(:expected_hash) do
        {
          json_key: 'json_value'
        }
      end

      it 'returns the file_hash representation of the file' do
        expect(json_file.read!).to eq(expected_hash)
      end
    end

    context 'when the file does not exist' do
      let(:expected_error) { /does not exist/ }

      it 'raises an error' do
        expect { json_file.read! }.to raise_error(expected_error)
      end
    end
  end

  describe '#write!' do
    let(:file_data) do
      {
        version: 987654321 # rubocop:disable Style/NumericLiterals
      }
    end
    let(:file_path) { File.join(temp_folder, 'test.json') }

    context 'when the file does not exist' do
      before do
        json_file.delete
      end

      it 'writes the file as json' do
        json_file.write!
        actual_hash = json_to_hash_for(file_path)
        expect(actual_hash).to eq(file_data)
      end
    end

    context 'when the file already exists' do
      it 'writes the file as json' do
        json_file.write!
        actual_hash = json_to_hash_for(file_path)
        expect(actual_hash).to eq(file_data)
      end
    end

    context 'when the validation fails' do
      subject(:json_file_write) { json_file.write! }

      let(:file_data) { nil }
      let(:expected_error) { /Validation failed/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#write' do
    context 'when the file_data argument is valid' do
      let(:file_data) do
        {
          version: 987654321 # rubocop:disable Style/NumericLiterals
        }
      end

      specify 'the file does not exist before the write' do
        expect(File.exist?(file_path)).to be false
      end

      it 'writes the file as json' do
        json_file.write
        actual_hash = json_to_hash_for(file_path)
        expect(actual_hash).to eq(file_data)
      end
    end
  end

  describe '#version' do
    context 'when the file does not exist' do
      it 'returns 0' do
        expect(json_file.version).to eq(0)
      end
    end

    context 'when the file exists and there is no version' do
      before do
        with_existing_file_path
      end

      it 'returns 0' do
        expect(json_file.version).to eq(0)
      end
    end

    context 'when the file exists and there is a version' do
      before do
        with_existing_file_path
      end

      let(:input_file) { 'spec/fixtures/files/json_file_with_version.json' }

      it 'returns the version' do
        expect(json_file.version).to eq(123_456_789)
      end
    end
  end
end
