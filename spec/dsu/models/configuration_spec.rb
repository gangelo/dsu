# frozen_string_literal: true

RSpec.describe Dsu::Models::Configuration do
  subject(:config) { described_class.instance.load(config_hash: config_hash) }

  before do
    create(:color_theme)
  end

  let(:config_hash) { described_class::DEFAULT_CONFIGURATION }

  describe 'constants' do
    describe 'VERSION' do
      it 'defines the right version type' do
        expect(described_class::VERSION).to be_a(Integer)
      end
    end

    describe 'DEFAULT_CONFIGURATION' do
      let(:expected_keys) do
        %i[
          version
          editor
          entries_display_order
          carry_over_entries_to_today
          include_all
          theme_name
        ]
      end

      it 'defines the right keys' do
        expect(described_class::DEFAULT_CONFIGURATION.keys).to match_array expected_keys
      end
    end
  end

  describe 'validations' do
    it 'validates #version attribute with the VersionValidator' do
      expect(described_class).to validate_with_validator(Dsu::Validators::VersionValidator)
    end

    describe '#editor' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge(editor: nil)
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
          described_class::DEFAULT_CONFIGURATION.merge(entries_display_order: nil)
        end
        let(:expected_errors) do
          [
            "Entries display order can't be blank",
            "Entries display order must be :asc or :desc"
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when not :asc or :desc' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge(entries_display_order: 'xyz')
        end
        let(:expected_errors) do
          [
            'Entries display order must be :asc or :desc'
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end

    describe '#carry_over_entries_to_today' do
      context 'when not present?' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge(carry_over_entries_to_today: nil)
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
          described_class::DEFAULT_CONFIGURATION.merge(carry_over_entries_to_today: 'foo')
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
          described_class::DEFAULT_CONFIGURATION.merge(include_all: nil)
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
          described_class::DEFAULT_CONFIGURATION.merge(include_all: 'foo')
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
          described_class::DEFAULT_CONFIGURATION.merge(theme_name: nil)
        end
        let(:expected_errors) do
          [
            "Theme name can't be blank",
            /Theme file ".+" does not exist/
          ]
        end

        it_behaves_like 'the validation fails'
      end

      context 'when the theme file does not exist' do
        let(:config_hash) do
          described_class::DEFAULT_CONFIGURATION.merge(theme_name: '/foo/bar/theme')
        end
        let(:expected_errors) do
          [
            /Theme file ".+" does not exist/
          ]
        end

        it_behaves_like 'the validation fails'
      end
    end
  end

  describe 'class methods' do
    describe '.exist?' do
      context 'when the config file exists' do
        it 'returns true' do
          expect(described_class.exist?).to be true
        end
      end

      context 'when the config file does not exist' do
        before do
          File.delete(described_class.config_path)
        end

        it 'returns false' do
          expect(described_class.exist?).to be false
        end
      end
    end
  end

  describe '#carry_over_entries_to_today?' do
    context 'when carry_over_entries_to_today is true' do
      let(:config_hash) do
        { carry_over_entries_to_today: true }
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
    before do
      config.save!
    end

    it 'returns a hash' do
      expect(described_class.instance.reload!.to_h).to eq described_class::DEFAULT_CONFIGURATION
    end
  end

  describe '#==' do
    before do
      config.save!
    end

    context 'when the other object is not a Configuration' do
      it 'returns false' do
        expect(described_class.instance.reload! == 'foo').to be false
      end
    end

    context 'when the configurations are equal' do
      it 'returns true' do
        expect(described_class.instance.reload!.to_h == described_class::DEFAULT_CONFIGURATION.dup).to be true
      end
    end
  end

  describe '#hash' do
    before do
      config.save!
    end

    let(:expected_hash) do
      described_class::DEFAULT_CONFIGURATION.each_key.map do |key|
        described_class.instance.public_send(key)
      end.hash
    end

    it 'returns the hash of all the attributes' do
      expect(config.hash).to eq expected_hash
    end
  end

  describe '#save!' do
    context 'when the configuration is valid' do
      let(:config_hash) do
        described_class::DEFAULT_CONFIGURATION.merge(editor: 'doom')
      end

      before do
        config.save!
      end

      it 'saves the configuration' do
        expect(described_class.exist?).to be true
      end

      it 'saves the configuration values' do
        expect(described_class.instance.reload!).to eq config
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

  describe '#merge' do
    let(:expected_config) do
      config.merge(edito: 'doom')
    end

    it 'merges the hash into the configuration hash and returns a new config' do
      config.editor = 'doom'
      expect(config).to eq expected_config
    end
  end
end
