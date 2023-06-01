# frozen_string_literal: true

RSpec.describe Dsu::Support::ColorThemeLocatable do
  subject(:color_theme_locatable) do
    Class.new do
      include Dsu::Support::ColorThemeLocatable

      attr_reader :theme_name

      def initialize(theme_name: nil)
        @theme_name = theme_name
      end
    end.new(theme_name: theme_name)
  end

  after do
    delete_color_theme!(theme_name: theme_name)
  end

  let(:theme_name) { 'foo' }
  let(:theme_hash) { Dsu::Models::ColorTheme::DEFAULT_THEME_HASH }

  describe '#theme_file_exist?' do
    context 'when the theme file does not exist' do
      it 'returns false' do
        expect(color_theme_locatable.theme_file_exist?).to be false
      end
    end

    context 'when the theme file exists' do
      before do
        create_color_theme!(theme_name: theme_name, theme_hash: theme_hash)
      end

      it 'returns true' do
        expect(color_theme_locatable.theme_file_exist?).to be true
      end
    end
  end

  describe '#theme_file' do
    it 'returns the correct theme file path' do
      themes_folder = Dsu::Models::Configuration::DEFAULT_CONFIGURATION['themes_folder']
      expected_theme_file = File.join(themes_folder, theme_name)
      expect(color_theme_locatable.theme_file).to eq expected_theme_file
    end
  end

  describe '#themes_folder' do
    it 'returns the correct themes folder' do
      expected_themes_folder = Dsu::Models::Configuration::DEFAULT_CONFIGURATION['themes_folder']
      expect(color_theme_locatable.themes_folder).to eq expected_themes_folder
    end
  end
end
