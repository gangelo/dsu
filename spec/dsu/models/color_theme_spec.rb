# frozen_string_literal: true

RSpec.describe Dsu::Models::ColorTheme do
  subject(:color_theme) { described_class }

  describe 'Theme' do
    subject(:color_theme_theme) do
      color_theme::Theme.new(theme_name: theme_name, theme_hash: theme_hash)
    end

    let(:theme_name) { described_class.default.theme_name }
    let(:theme_hash) { described_class::DEFAULT_THEME_HASH }

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
        let(:theme_hash) { nil }
        let(:expected_error) { 'theme_hash is nil.' }

        it_behaves_like 'an error is raised'
      end

      context 'when theme_hash is not a Hash' do
        let(:theme_hash) { 1 }
        let(:expected_error) { /theme_hash is the wrong object type:/ }

        it_behaves_like 'an error is raised'
      end
    end
  end
end
