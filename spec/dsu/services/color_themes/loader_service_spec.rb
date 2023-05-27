# frozen_string_literal: true

RSpec.describe Dsu::Services::ColorThemes::LoaderService do
  subject(:loader_service) do
    described_class.new(theme_name: theme_name)
  end

  let(:theme_name) { 'test_theme' }

  context 'when the theme_name is invalid' do
    context 'when theme_name is not a String' do
      it 'raises an error'
    end

    context 'when theme_name is nil' do
      it 'does not raise an error'
    end
  end

  context 'when the theme_name is valid' do
    it 'returns the color theme'
  end

  context 'when the theme does not exist' do
    it 'returns the default color theme'
  end

  context 'when the color theme exists and has differnent keys than the default color theme' do
    it 'updates the color theme file and returns the updated color theme'
  end
end
