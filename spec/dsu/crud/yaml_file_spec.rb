# frozen_string_literal: true

RSpec.describe Dsu::Crud::YamlFile do
  subject(:yaml_file) { described_class.new(file_path: file_path, options: options) }

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

  let(:input_file) { 'spec/fixtures/files/yaml_file.yaml' }
  let(:file_path) { temp_file.path }
  let(:with_existing_file_path) do
    raise "The fixture file (#{input_file}) does not exist" unless File.exist?(input_file)

    file_data = File.read(input_file)
    File.write(temp_file, file_data)
  end
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

  describe '#read' do
    before do
      with_existing_file_path
    end

    let(:expected_file_data) do
      {
        'yaml_key' => 'yaml_value' # rubocop:disable Style/StringHashKeys
      }
    end

    it 'returns the file_hash representation of the file' do
      expect(yaml_file.read).to eq(expected_file_data)
    end
  end

  describe '#read!' do
    context 'when the file exists' do
      before do
        with_existing_file_path
      end

      let(:expected_file_data) do
       {
        'yaml_key' => 'yaml_value' # rubocop:disable Layout/FirstHashElementIndentation
       }
      end

      it 'returns the file_hash representation of the file' do
        expect(yaml_file.read!).to eq(expected_file_data)
      end
    end

    context 'when the file does not exist' do
      subject(:yaml_file) { described_class.new(file_path: file_path, options: options).read! }

      let(:expected_error) { /does not exist/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#write!' do
    subject(:yaml_file) do
      described_class.new(file_path: file_path, options: options).write!(file_hash: file_hash)
    end

    let(:file_hash) do
      {
        'yaml_key' => 'yaml_value'
      }
    end
    let(:file_path) { File.join(temp_folder, 'test.yaml') }

    context 'when the file does not exist' do
      before do
        File.delete(file_path)
      end

      it 'writes the file as yaml' do
        yaml_file
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
    subject(:yaml_file) do
      described_class.new(file_path: file_path, options: options).write(file_hash: file_hash)
    end

    context 'when the file_hash argument is valid' do
      let(:file_hash) do
        {
          'yaml_key' => 'yaml_value'
        }
      end

      specify 'the file does not exist before the write' do
        expect(File.exist?(file_path)).to be false
      end

      it 'writes the file as yaml' do
        yaml_file
        actual_hash = described_class.new(file_path: file_path, options: options).read!
        expect(actual_hash).to eq(file_hash)
      end
    end

    context 'when the file_hash argument is invalid' do
      it_behaves_like 'the correct file_hash: argument errors are raised'
    end
  end

  describe '#version' do
    subject(:yaml_file) do
      described_class.new(file_path: file_path, options: options).version
    end

    context 'when the file does not exist' do
      it 'returns 0' do
        expect(yaml_file).to eq(0)
      end
    end

    context 'when the file exists and there is no version' do
      before do
        with_existing_file_path
      end

      it 'returns 0' do
        expect(yaml_file).to eq(0)
      end
    end

    context 'when the file exists and there is a version' do
      before do
        with_existing_file_path
      end

      let(:input_file) { 'spec/fixtures/files/yaml_file_with_version.yaml' }

      it 'returns the version' do
        expect(yaml_file).to eq(123_456_789)
      end
    end
  end
end
