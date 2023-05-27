# frozen_string_literal: true

RSpec.describe Dsu::Services::ColorThemes::LoaderService do
  subject(:loader_service) do
    described_class.new(theme_name: theme_name)
  end

  let(:theme_name) { 'test_theme' }

  describe '#initialize' do
    context 'when theme_name is nil' do
      let(:theme_name) { nil }

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
      it 'returns the loaded color theme'
    end

    context 'when the color theme file exists and has differnent keys than the default color theme' do
      it 'updates the color theme file and returns the updated color theme'
    end
  end
end
