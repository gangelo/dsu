# frozen_string_literal: true

RSpec.describe Dsu::Models::ColorTheme do
  subject(:color_theme) do
    described_class.new(theme_name: theme_name, theme_hash: theme_hash)
  end

  before do
    create_config_file!
  end

  after do
    delete_default_color_theme!
    # NOTE: deleting the above defaut color theme is dependent on the
    # configuration file being present. So, we delete the configuration file
    # last.
    delete_config_file!
  end

  let(:theme_name) { described_class.default.theme_name }
  let(:theme_hash) { described_class::DEFAULT_THEME }

  describe '#initialize' do
    context 'when theme_name is nil' do
      let(:theme_name) { nil }
      let(:expected_error) { 'theme_name is nil.' }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_name is not a String' do
      let(:theme_name) { 1 }
      let(:expected_error) { /theme_name is the wrong object type:/ }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_hash is nil' do
      let(:theme_name) { 'customized' }
      let(:theme_hash) { nil }
      let(:expected_color_theme) do
        theme_hash = described_class::DEFAULT_THEME.merge(description: 'Customized theme')
        described_class.new(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'initializes a color theme with the default theme and customized description' do
        expect(color_theme).to eq expected_color_theme
      end
    end

    context 'when theme_hash is not a Hash' do
      let(:theme_hash) { 1 }
      let(:expected_error) { /theme_hash is the wrong object type:/ }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_hash is not a valid theme hash' do
      let(:theme_hash) do
        described_class::DEFAULT_THEME.merge(foo: :bar)
      end
      let(:expected_error) { /theme_hash keys are missing or invalid:/ }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_hash is a valid theme hash' do
      it 'creates attributes for each theme hash key' do
        expect(described_class::DEFAULT_THEME.each_key.all? do |key|
          color_theme.respond_to?(key)
        end).to eq true
      end

      it 'assigns the correct attribute values' do
        expect(described_class::DEFAULT_THEME.each.all? do |key, value|
          color_theme.public_send(key) == value
        end).to eq true
      end
    end
  end

  describe 'instance methods' do
    describe '#exist?' do
      it 'returns true if the theme file exists' do
        create_default_color_theme!
        expect(color_theme.exist?).to be true
      end

      it 'returns false if the theme file does not exist' do
        expect(color_theme.exist?).to be false
      end
    end

    describe '#theme_name' do
      it 'returns the correct theme name' do
        expect(color_theme.theme_name).to eq theme_name
      end
    end

    describe '#theme_hash' do
      it 'returns the correct theme hash' do
        expect(color_theme.to_h).to eq theme_hash
      end
    end

    describe '==' do
      it 'returns true if the themes are the same' do
        expect(color_theme == described_class.default).to be true
      end

      it 'returns false if the themes are different' do
        different_color_theme = described_class.new(theme_name: 'Different', theme_hash: theme_hash)
        expect(different_color_theme == described_class.default).to be false
      end
    end

    describe '#hash' do
      context 'when the themes are the same' do
        it 'returns the same hash' do
          expect(color_theme.hash).to eq described_class.default.hash
        end
      end

      context 'when the themes are different' do
        it 'returns a different hash' do
          different_color_theme = described_class.new(theme_name: 'Different', theme_hash: theme_hash)
          expect(different_color_theme.hash).not_to eq described_class.default.hash
        end
      end
    end
  end

  describe 'class constants' do
    describe 'DEFAULT_THEME' do
      let(:expected_default_theme_hash) do
        {
          version: described_class.version,
          description: 'Default theme',
          entry_group: :highlight,
          entry: :highlight,
          status_info: :cyan,
          status_success: :green,
          status_warning: :yellow,
          status_error: :red,
          state_highlight: :cyan
        }
      end

      it 'returns the correct default theme hash' do
        expect(described_class::DEFAULT_THEME).to eq(expected_default_theme_hash)
      end
    end

    describe 'DEFAULT_THEME_NAME' do
      it 'returns the correct default theme name' do
        expect(described_class::DEFAULT_THEME_NAME).to eq('default')
      end
    end
  end

  describe 'class methods' do
    describe '.version' do
      it 'returns the current dsu version' do
        expect(described_class.version).to eq(described_class.version)
      end
    end

    describe '.default' do
      let(:expected_default_color_theme) do
        described_class.new(theme_name: described_class::DEFAULT_THEME_NAME,
          theme_hash: described_class::DEFAULT_THEME)
      end

      it 'returns the default color theme' do
        expect(described_class.default).to eq(expected_default_color_theme)
      end
    end
  end
end
