# frozen_string_literal: true

RSpec.describe Dsu::Models::ColorTheme do
  subject(:color_theme) do
    described_class.new(theme_name: theme_name, theme_hash: theme_hash)
  end

  shared_examples 'the color theme exists' do
    it 'the color theme file exists' do
      expect(described_class.exist?(theme_name: theme_name)).to be(true)
    end
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

    context 'when theme_hash contains extra key/value pairs' do
      let(:theme_hash) do
        described_class::DEFAULT_THEME.merge(foo: :bar)
      end

      it_behaves_like 'no error is raised'
    end

    context 'when theme_hash is a valid theme hash' do
      it 'creates attributes for each theme hash key' do
        expect(described_class::DEFAULT_THEME.each_key.all? do |key|
          color_theme.respond_to?(key)
        end).to eq true
      end

      it 'makes sure all the color theme colors are accounted for and assigns the color theme attribute values' do
        expect(described_class::DEFAULT_THEME_COLORS.each.all? do |key, value|
          color_theme.public_send(key) == value.merge_default_colors
        end).to eq true
      end
    end
  end

  describe 'constants' do
    it 'defines VERSION' do
      expect(described_class::VERSION).to eq 20230613121411 # rubocop:disable Style/NumericLiterals
    end

    it_behaves_like 'the version is a valid version'
  end

  describe 'validations' do
    it 'validates #description with DescriptionValidator' do
      expect(color_theme).to validate_with_validator(Dsu::Validators::DescriptionValidator)
    end

    it 'validates the color theme color attributes with the ColorThemeValidator' do
      expect(color_theme).to validate_with_validator(Dsu::Validators::ColorThemeValidator)
    end

    it 'validates #version attribute with the VersionValidator' do
      expect(color_theme).to validate_with_validator(Dsu::Validators::VersionValidator)
    end
  end

  describe 'instance methods' do
    describe '#theme_name' do
      it 'returns the correct theme name' do
        expect(color_theme.theme_name).to eq theme_name
      end
    end

    describe '#theme_hash' do
      let(:expected_color_theme) do
        described_class.ensure_color_theme_color_defaults_for(theme_hash: theme_hash)
      end

      it 'returns the correct theme hash' do
        expect(color_theme.to_h).to eq expected_color_theme
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

    describe '#delete' do
      before do
        color_theme.write
      end

      it 'deletes the theme file' do
        color_theme.delete!
        expect(color_theme.exist?).to be false
      end

      context 'when the theme is the current theme in the configuration' do
        before do
          Dsu::Models::Configuration.instance.tap do |configuration|
            configuration.theme_name = theme_name
            configuration.write
          end
        end

        let(:theme_name) { 'test' }

        it_behaves_like 'the color theme is the current color theme in the configuration'

        it_behaves_like 'the color theme exists'

        it 'deletes the theme file' do
          color_theme.delete!
          expect(described_class.exist?(theme_name: theme_name)).to be(false)
        end
      end

      context 'when the theme is not the current theme in the configuration' do
        before do
          big_red = described_class.find_or_create(theme_name: 'big_red')
          Dsu::Models::Configuration.instance.tap do |configuration|
            configuration.theme_name = big_red.theme_name
            configuration.write
          end
        end

        let(:theme_name) { 'test' }

        it_behaves_like 'the color theme is not the current color theme in the configuration'

        it_behaves_like 'the color theme exists'

        it 'deletes the theme file' do
          color_theme.delete!
          expect(described_class.exist?(theme_name: theme_name)).to be(false)
        end

        it 'does not change the current theme in the configuration' do
          expect(Dsu::Models::Configuration.instance.theme_name).to eq('big_red')
        end
      end
    end
  end

  describe 'class constants' do
    describe 'DEFAULT_THEME' do
      let(:expected_default_theme_hash) do
        {
          version: described_class::VERSION,
          description: 'Default theme.',
          help: { color: :cyan },
          dsu_header: { color: :white, mode: :bold, background: :cyan },
          dsu_footer: { color: :cyan },
          header: { color: :cyan, mode: :bold },
          subheader: { color: :cyan, mode: :underline },
          body: { color: :cyan },
          footer: { color: :light_cyan },
          date: { color: :cyan, mode: :bold },
          index: { color: :light_cyan },
          # Status colors.
          info: { color: :cyan },
          success: { color: :green },
          warning: { color: :yellow },
          error: { color: :light_yellow, background: :red },
          # Prompts
          prompt: { color: :cyan, mode: :bold },
          prompt_options: { color: :white, mode: :bold }
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
    describe '.current_or_default' do
      context 'when the configuration theme is set to the default theme' do
        before do
          described_class.default.write
        end

        it 'returns the default color theme' do
          expect(described_class.current_or_default).to eq(described_class.default)
        end
      end

      context 'when the configuration theme is set to a custom theme' do
        before do
          custom_color_theme
          configuration = Dsu::Models::Configuration.instance
          configuration.theme_name = custom_color_theme.theme_name
          configuration.write
        end

        let(:custom_color_theme) do
          described_class.find_or_create(theme_name: 'customized')
        end

        it 'returns the custom color theme' do
          expect(described_class.current_or_default).to eq(custom_color_theme)
        end
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
