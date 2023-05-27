# frozen_string_literal: true

RSpec.describe Dsu::Services::ColorThemes::WriterService do
  subject(:writer_service) { described_class.new(theme: theme) }

  after do
    # TODO: Delete the theme file
    if theme_name.is_a?(Dsu::Models::ColorTheme::Theme) &&
       color_theme_class.theme_file?(theme_name: theme_name)
      File.delete(color_theme_class.theme_file(theme_name: theme_name))
    end

    if color_theme_class.theme_file?(theme_name: color_theme_class.default.theme_name)
      File.delete(color_theme_class.theme_file(theme_name: color_theme_class.default.theme_name))
    end
  end

  let(:color_theme_class) { Dsu::Models::ColorTheme }
  let(:theme_name) { theme.try(:theme_name) }
  let(:theme) { Dsu::Models::ColorTheme.default }

  describe '#initialize' do
    context 'when theme is nil' do
      let(:theme) { nil }
      let(:expected_error) { 'theme is nil.' }

      it_behaves_like 'an error is raised'
    end

    context 'when theme is not a Theme' do
      let(:theme) { 1 }
      let(:expected_error) { /theme is the wrong object type:/ }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#call' do
    context 'when the theme file does not exist' do
      let(:theme_name) { expected_color_theme.theme_name }
      let(:expected_color_theme) { Dsu::Models::ColorTheme.default }

      it 'makes sure the theme file does not exist before the test' do
        expect(color_theme_class.theme_file?(theme_name: theme_name)).to eq false
      end

      it 'wites (creates) the color theme file' do
        writer_service.call
        expect(color_theme_class.theme_file?(theme_name: theme_name)).to eq true
      end
    end

    context 'when the theme file exists and has the same keys as the default color theme' do
      it 'returns the loaded color theme'
    end

    context 'when the color theme file exists and has differnent keys than the default color theme' do
      it 'updates the color theme file and returns the updated color theme'
    end
  end

  describe '#call!' do
    context 'when the theme file already exists' do
      subject(:writer_service_call) { writer_service.call! }

      before do
        # This creates the file before our test.
        writer_service.call
      end

      let(:expected_error) { /Theme file already exists for theme "#{theme.theme_name}"/ }

      it_behaves_like 'an error is raised'
    end
  end
end
