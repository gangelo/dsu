# frozen_string_literal: true

RSpec.describe Dsu::Crud::JsonFile do
  subject(:json_file) { described_class.new(file_path: file_path, options: options) }

  shared_examples 'the correct file_hash: argument errors are raised' do
    context 'when nil' do
      let(:file_hash) { nil }
      let(:expected_error) { /file_hash is nil/ }

      it_behaves_like 'an error is raised'
    end

    context 'when not a Hash' do
      let(:file_hash) { :invalid }
      let(:expected_error) { /file_hash is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end
  end

  before do
    File.delete(temp_file)
  end

  let(:with_existing_file_path) do
    file_path = 'spec/fixtures/files/json_file.json'
    raise "The fixture file (#{file_path}) does not exist" unless File.exist?(file_path)

    file_hash = JSON.parse(File.read(file_path))
    File.write(temp_file, JSON.pretty_generate(file_hash))
  end
  let(:file_path) { temp_file.path }
  let(:options) { {} }

  describe '#initialize' do
    context 'when the arguments are valid' do
      it_behaves_like 'no error is raised'
    end

    context 'when file_path: is invalid' do
      context 'when nil' do
        let(:file_path) { nil }
        let(:expected_error) { /file_path is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when not a String' do
        let(:file_path) { :invalid }
        let(:expected_error) { /file_path is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end
    end

    context 'when options: is invalid' do
      context 'when nil' do
        let(:options) { nil }
        let(:expected_error) { /options is nil/ }

        it_behaves_like 'an error is raised'
      end

      context 'when not a Hash' do
        let(:options) { :invalid }
        let(:expected_error) { /options is the wrong object type/ }

        it_behaves_like 'an error is raised'
      end
    end
  end

  describe '#exist?' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      it 'returns true' do
        expect(json_file.exist?).to be true
      end
    end

    context 'when the file does not exist' do
      let(:file_path) { '$invalid path$' }

      it 'returns false' do
        expect(json_file.exist?).to be false
      end
    end
  end

  describe '#read' do
    before do
      with_existing_file_path
    end

    let(:expected_hash) do
      {
        version: 1_234_567_890
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
          version: 1_234_567_890
        }
      end

      it 'returns the file_hash representation of the file' do
        expect(json_file.read).to eq(expected_hash)
      end
    end

    context 'when the file does not exist' do
      subject(:json_file) { described_class.new(file_path: file_path, options: options).read! }

      let(:expected_error) { /does not exist/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#write!' do
    subject(:json_file) do
      described_class.new(file_path: file_path, options: options).write!(file_hash: file_hash)
    end

    let(:file_hash) do
      {
        version: 987_654_321
      }
    end
    let(:file_path) { File.join(temp_folder, 'test.json') }

    context 'when the file_hash argument is valid' do
      before do
        File.delete(file_path)
      end

      it 'writes the file as json' do
        json_file
        actual_hash = described_class.new(file_path: file_path, options: options).read!
        expect(actual_hash).to eq(file_hash)
      end
    end

    context 'when the file already exists' do
      before do
        described_class.new(file_path: file_path, options: options).write(file_hash: file_hash)
      end

      let(:expected_error) { /already exists/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#write' do
    subject(:json_file) do
      described_class.new(file_path: file_path, options: options).write(file_hash: file_hash)
    end

    context 'when the file_hash argument is valid' do
      let(:file_hash) do
        {
          version: 987_654_321
        }
      end

      specify 'the file does not exist before the write' do
        expect(File.exist?(file_path)).to be false
      end

      it 'writes the file as json' do
        json_file
        actual_hash = described_class.new(file_path: file_path, options: options).read!
        expect(actual_hash).to eq(file_hash)
      end
    end

    context 'when the file_hash argument is invalid' do
      it_behaves_like 'the correct file_hash: argument errors are raised'
    end
  end

  describe 'delete' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      specify 'the file exists before the delete' do
        expect(File.exist?(file_path)).to be true
      end

      it 'deletes the file' do
        json_file.delete
        expect(File.exist?(file_path)).to be false
      end
    end

    context 'when the file does not exist' do
      subject(:json_file) { described_class.new(file_path: file_path, options: options).delete }

      specify 'the file does not exist before the delete' do
        expect(File.exist?(file_path)).to be false
      end

      it 'returns false' do
        expect(json_file).to be false
      end
    end
  end

  describe 'delete!' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      specify 'the file exists before the delete' do
        expect(File.exist?(file_path)).to be true
      end

      it 'deletes the file' do
        json_file.delete!
        expect(File.exist?(file_path)).to be false
      end
    end

    context 'when the file does not exist' do
      subject(:json_file) { described_class.new(file_path: file_path, options: options).delete! }

      let(:expected_error) { /does not exist/ }

      specify 'the file does not exist before the delete' do
        expect(File.exist?(file_path)).to be false
      end

      it_behaves_like 'an error is raised'
    end
  end
end
