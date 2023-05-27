# frozen_string_literal: true

RSpec.describe Dsu::Services::ColorThemes::LoaderService do
  subject(:loader_service) { described_class.new(theme_name: theme_name) }

  after do
    delete_default_color_theme!
    delete_color_theme!(theme_name: theme_name) if theme_name.is_a?(String)
  end

  let(:theme_name) { 'test_theme' }

  describe '#initialize' do
    context 'when theme_name is nil' do
      let(:theme_name) { nil }

      # Because the the default theme is used in that case.
      it_behaves_like 'no error is raised'
    end

    context 'when theme_name is not a String' do
      let(:theme_name) { 1 }
      let(:expected_error) { 'theme_name must be a String: "1".' }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#call' do
    context 'when the theme file does not exist' do
      let(:theme_name) { expected_color_theme.theme_name }
      let(:expected_color_theme) { Dsu::Models::ColorTheme.default }

      it 'returns the default color theme' do
        expect(loader_service.call).to eq(expected_color_theme)
      end
    end

    context 'when the theme file exists and has the same keys as the default color theme' do
      before do
        create_color_theme!(theme_name: theme_name, theme_hash: theme_hash)
      end

      let(:theme_hash) do
        Dsu::Models::ColorTheme::DEFAULT_THEME_HASH.merge({ description: 'Test theme description' })
      end

      it 'returns the loaded color theme' do
        expect(loader_service.call).to eq(Dsu::Models::ColorTheme::Theme.new(theme_name: theme_name, theme_hash: theme_hash))
      end
    end

    context 'when the color theme file exists and has less keys than the default color theme' do
      before do
        create_default_color_theme!
        stub_const('Dsu::Models::ColorTheme::DEFAULT_THEME_HASH', mocked_default_color_theme)
      end

      # These options represent (for example) a user updates this gem, and the dsu config
      # options have changed and they would be
      let(:mocked_default_color_theme) do
        Dsu::Models::ColorTheme::DEFAULT_THEME_HASH.dup.tap do |default_color_theme|
          default_color_theme[:new_option_one] = :new_option_one
          default_color_theme[:new_option_two] = :new_option_two
        end
      end
      let(:theme_name) { Dsu::Models::ColorTheme.default.theme_name }
      let(:expected_color_theme) do
        Dsu::Models::ColorTheme::Theme.new(theme_name: theme_name, theme_hash: mocked_default_color_theme)
      end

      it 'updates the color theme file and returns the updated color theme' do
        expect(loader_service.call).to eq(expected_color_theme)
      end
    end

    context 'when the color theme file exists and has more keys than the default color theme' do
      it 'updates the color theme file and returns the updated color theme'
    end
  end
end
