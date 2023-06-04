# frozen_string_literal: true

# rubocop:disable Style/StringHashKeys
RSpec.describe Dsu::Models::Configuration do
  subject(:config) { described_class.new(config_hash: config_hash) }

  before do
    create_default_color_theme!
  end

  after do
    delete_default_color_theme!
    delete_config_file!
  end

  let(:config_hash) { described_class::DEFAULT_CONFIGURATION }

  describe 'constants' do
    describe 'DEFAULT_CONFIGURATION' do
      let(:expected_keys) do
        %w[
          version
          editor
          entries_display_order
          entries_folder
          entries_file_name
          carry_over_entries_to_today
          include_all
          theme_name
          themes_folder
        ]
      end

      it 'defines the right keys' do
        expect(described_class::DEFAULT_CONFIGURATION.keys).to match_array expected_keys
      end
    end
  end

  describe 'validations' do
    describe '#version' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('version' => nil)
        end
        let(:expected_errors) do
          [
            "Version can't be blank",
            "Version must match the format '#.#.#[.alpha.#]' where # is 0-n"
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when not the correct format' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('version' => 'a.b.c')
        end
        let(:expected_errors) do
          [
            "Version must match the format '#.#.#[.alpha.#]' where # is 0-n"
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#editor' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('editor' => nil)
        end
        let(:expected_errors) do
          [
            "Editor can't be blank"
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#entries_display_order' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('entries_display_order' => nil)
        end
        let(:expected_errors) do
          [
            "Entries display order can't be blank",
            "Entries display order must be 'asc' or 'desc'"
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when not asc or desc' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('entries_display_order' => 'xyz')
        end
        let(:expected_errors) do
          [
            "Entries display order must be 'asc' or 'desc'"
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#entries_file_name' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('entries_file_name' => nil)
        end
        let(:expected_errors) do
          [
            "Entries file name can't be blank",
            "Entries file name must include the Time#strftime format specifiers '%Y %m %d' " \
            'and be a valid file name for your operating system'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context "when it doesn't include the required Time format specified" do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('entries_file_name' => '%Y-%d-no-month')
        end
        let(:expected_errors) do
          [
            "Entries file name must include the Time#strftime format specifiers '%Y %m %d' " \
            'and be a valid file name for your operating system'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#entries_folder' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('entries_folder' => nil)
        end
        let(:expected_errors) do
          [
            "Entries folder can't be blank"
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when it is not a valid folder' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('entries_folder' => './foo/bar')
        end
        let(:expected_errors) do
          [
            /Entries folder .+ does not exist/
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#carry_over_entries_to_today' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('carry_over_entries_to_today' => nil)
        end
        let(:expected_errors) do
          [
            'Carry over entries to today must be true or false'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when not true or false' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('carry_over_entries_to_today' => 'foo')
        end
        let(:expected_errors) do
          [
            'Carry over entries to today must be true or false'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#include_all' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('include_all' => nil)
        end
        let(:expected_errors) do
          [
            'Include all must be true or false'
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when not true or false' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('include_all' => 'foo')
        end
        let(:expected_errors) do
          [
            'Include all must be true or false'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#theme' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('theme_name' => nil)
        end
        let(:expected_errors) do
          [
            "Theme name can't be blank"
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when the theme file does not exist' do
        subject(:config) { described_class.new(config_hash: config_hash) }

        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('theme_name' => '/foo/bar/theme')
        end
        let(:expected_errors) do
          [
            /Theme file ".+" does not exist/
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#themes_folder' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('themes_folder' => nil)
        end
        let(:expected_errors) do
          [
            "Themes folder can't be blank"
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when it is not a valid folder' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge('themes_folder' => './foo/bar')
        end
        let(:expected_errors) do
          [
            /Themes folder ".+" does not exist/
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end
  end

  describe 'class methods' do
    describe '.current_or_default' do
      context 'when there is no current configuration' do
        it 'returns the default configuration' do
          expect(described_class.current_or_default).to eq(described_class.default)
        end
      end

      context 'when there is a current configuration' do
        before do
          current_config.save!
        end

        let(:current_config) do
          described_class.default.merge('editor' => 'doom')
        end

        it 'returns the current configuration' do
          expect(described_class.current_or_default).to eq(current_config)
        end
      end
    end

    describe '.current' do
      context 'when there is no current configuration' do
        it 'returns nil' do
          expect(described_class.current).to be nil
        end
      end

      context 'when there is a current configuration' do
        before do
          current_config.save!
        end

        let(:current_config) do
          described_class.default.merge('editor' => 'doom')
        end

        it 'returns the current configuration' do
          expect(described_class.current).to eq(current_config)
        end
      end
    end

    describe '.default' do
      it 'returns the default configuration' do
        default_config = described_class.new(config_hash: described_class::DEFAULT_CONFIGURATION)
        expect(described_class.default).to eq(default_config)
      end
    end

    describe '.delete!' do
      context 'when the config file exists' do
        before do
          described_class.current_or_default.save!
        end

        it 'deletes the config file' do
          described_class.delete!
          expect(described_class.exist?).to be false
        end
      end

      context 'when the config file does not exist' do
        subject(:config) { described_class.delete! }

        let(:expected_error) do
          /Config file does not exist/
        end

        it_behaves_like 'an error is raised'
      end
    end

    describe '.config_path' do
      it 'returns the correct config file name' do
        expect(described_class.config_path).to eq File.join(Dir.home, '.dsu')
      end
    end

    describe '.exist?' do
      context 'when the config file exists' do
        before do
          described_class.current_or_default.save!
        end

        it 'returns true' do
          expect(described_class.exist?).to be true
        end
      end

      context 'when the config file does not exist' do
        it 'returns false' do
          expect(described_class.exist?).to be false
        end
      end
    end

    describe '.config_folder' do
      it 'returns the config folder' do
        expect(described_class.config_folder).to eq Dsu::Support::FolderLocations.root_folder
      end
    end
  end

  describe '#carry_over_entries_to_today?' do
    context 'when carry_over_entries_to_today is true' do
      let(:config_hash) do
        { 'carry_over_entries_to_today' => true }
      end

      it 'returns true' do
        expect(config.carry_over_entries_to_today?).to be true
      end
    end

    context 'when carry_over_entries_to_today is false' do
      it 'returns false' do
        expect(config.carry_over_entries_to_today?).to be false
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash' do
      expect(described_class.default.to_h).to eq described_class::DEFAULT_CONFIGURATION
    end
  end

  describe '#==' do
    context 'when the other object is not a Configuration' do
      it 'returns false' do
        expect(described_class.default == 'foo').to be false
      end
    end

    context 'when the configurations are equal' do
      it 'returns true' do
        expect(described_class.default.to_h == described_class::DEFAULT_CONFIGURATION.dup).to be true
      end
    end
  end

  describe '#hash' do
    let(:expected_hash) do
      default_config = described_class.default
      described_class::DEFAULT_CONFIGURATION.each_key.map do |key|
        default_config.public_send(key.to_sym)
      end.hash
    end

    it 'returns the hash of all the attributes' do
      expect(described_class.default.hash).to eq expected_hash
    end
  end

  describe '#save!' do
    context 'when the configuration is valid' do
      let(:config_hash) do
        described_class::DEFAULT_CONFIGURATION.merge('editor' => 'doom')
      end

      before do
        config.save!
      end

      it 'saves the configuration' do
        expect(described_class.exist?).to be true
      end

      it 'saves the configuration values' do
        expect(described_class.current).to eq config
      end
    end

    context 'when the configuration is not valid' do
      before do
        config.editor = nil
      end

      let(:expected_error) do
        /Editor can't be blank/
      end

      it 'raises an error' do
        expect { config.save! }.to raise_error(expected_error)
      end
    end
  end

  describe '#delete!' do
    context 'when the configuration exists' do
      before do
        config.save!
      end

      it 'makes sure the config file exists prior to the test' do
        expect(described_class.exist?).to be true
      end

      it 'deletes the configuration' do
        config.delete!
        expect(described_class.exist?).to be false
      end
    end

    context 'when the configuration does not exist' do
      subject(:config) { described_class.new(config_hash: config_hash).delete! }

      let(:expected_error) do
        /Config file does not exist/
      end

      it_behaves_like 'an error is raised'
    end
  end

  describe '#merge' do
    let(:expected_config) do
      config.merge('editor' => 'doom')
    end

    it 'merges the hash into the configuration hash and returns a new config' do
      config.editor = 'doom'
      expect(config).to eq expected_config
    end
  end
end
# rubocop:enable Style/StringHashKeys
