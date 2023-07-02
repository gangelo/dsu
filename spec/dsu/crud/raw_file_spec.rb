# frozen_string_literal: true

RSpec.describe Dsu::Crud::RawFile do
  subject(:raw_file) { described_class.new(file_path: file_path, options: options) }

  shared_examples 'the correct file_data: argument errors are raised' do
    context 'when nil' do
      let(:file_data) { nil }
      let(:expected_error) { /file_data is nil/ }

      it_behaves_like 'an error is raised'
    end

    context 'when not a Hash' do
      let(:file_data) { :invalid }
      let(:expected_error) { /file_data is the wrong object type/ }

      it_behaves_like 'an error is raised'
    end
  end

  before do
    File.delete(temp_file)
  end

  let(:with_existing_file_path) do
    file_path = 'spec/fixtures/files/raw_file.txt'
    raise "The fixture file (#{file_path}) does not exist" unless File.exist?(file_path)

    file_data = File.read(file_path)
    File.write(temp_file, file_data)
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
        expect(raw_file.exist?).to be true
      end
    end

    context 'when the file does not exist' do
      let(:file_path) { '$invalid path$' }

      it 'returns false' do
        expect(raw_file.exist?).to be false
      end
    end
  end

  describe '#read' do
    before do
      with_existing_file_path
    end

    let(:expected_data) { "raw file data\n" }

    it 'returns the file_data representation of the file' do
      expect(raw_file.read).to eq(expected_data)
    end
  end

  describe '#read!' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      let(:expected_data) { "raw file data\n" }

      it 'returns the file_data representation of the file' do
        expect(raw_file.read).to eq(expected_data)
      end
    end

    context 'when the file does not exist' do
      subject(:raw_file) { described_class.new(file_path: file_path, options: options).read! }

      let(:expected_error) { /does not exist/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#write!' do
    subject(:raw_file) do
      described_class.new(file_path: file_path, options: options).write!(file_data: file_data)
    end

    let(:file_data) { 'file data' }
    let(:file_path) { File.join(temp_folder, 'test.json') }

    context 'when the file does not exist' do
      before do
        File.delete(file_path)
      end

      it 'writes the file as json' do
        raw_file
        actual_data = described_class.new(file_path: file_path, options: options).read!
        expect(actual_data).to eq(file_data)
      end
    end

    context 'when the file already exists' do
      before do
        described_class.new(file_path: file_path, options: options).write(file_data: file_data)
      end

      let(:expected_error) { /already exists/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#write' do
    subject(:raw_file) do
      described_class.new(file_path: file_path, options: options).write(file_data: file_data)
    end

    context 'when the file_data argument is valid' do
      let(:file_data) { 'file data' }

      specify 'the file does not exist before the write' do
        expect(File.exist?(file_path)).to be false
      end

      it 'writes the file' do
        raw_file
        actual_data = described_class.new(file_path: file_path, options: options).read!
        expect(actual_data).to eq(file_data)
      end
    end

    context 'when the file_data argument is invalid' do
      it_behaves_like 'the correct file_data: argument errors are raised'
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
        raw_file.delete
        expect(File.exist?(file_path)).to be false
      end
    end

    context 'when the file does not exist' do
      subject(:raw_file) { described_class.new(file_path: file_path, options: options).delete }

      specify 'the file does not exist before the delete' do
        expect(File.exist?(file_path)).to be false
      end

      it 'returns false' do
        expect(raw_file).to be false
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
        raw_file.delete!
        expect(File.exist?(file_path)).to be false
      end
    end

    context 'when the file does not exist' do
      subject(:raw_file) { described_class.new(file_path: file_path, options: options).delete! }

      let(:expected_error) { /does not exist/ }

      specify 'the file does not exist before the delete' do
        expect(File.exist?(file_path)).to be false
      end

      it_behaves_like 'an error is raised'
    end
  end
end
