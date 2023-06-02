# frozen_string_literal: true

RSpec.shared_examples 'the color theme file is created' do
  it 'wites (creates) the color theme file' do
    writer_service.call
    expect(Dsu::Models::ColorTheme.theme_file_exist?(theme_name: theme_name)).to be true
  end
end

RSpec.shared_examples 'the color theme file exists' do
  it 'confirms that the color theme file exists' do
    expect(Dsu::Models::ColorTheme.theme_file_exist?(theme_name: theme_name)).to be true
  end
end

RSpec.shared_examples 'the color theme file does not exist' do
  it 'confirms that the color theme file does not exist' do
    expect(Dsu::Models::ColorTheme.theme_file_exist?(theme_name: theme_name)).to be false
  end
end

RSpec.describe Dsu::Services::ColorTheme::WriterService do
  subject(:writer_service) { described_class.new(theme_name: theme_name, theme_hash: theme_hash) }

  after do
    delete_default_color_theme!
    if theme_name.is_a?(String) && !theme_name.empty?
      delete_color_theme!(theme_name: theme_name)
    end
  end

  let(:theme_name) { Dsu::Models::ColorTheme::DEFAULT_THEME_NAME }
  let(:theme_hash) { Dsu::Models::ColorTheme::DEFAULT_THEME }

  describe '#initialize' do
    context 'when theme_name is nil' do
      let(:theme_name) { nil }
      let(:expected_error) { 'theme_name cannot be nil' }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_name is not a string' do
      let(:theme_name) { :not_a_string }
      let(:expected_error) { /theme_name must be a String/ }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_name is blank' do
      let(:theme_name) { '' }
      let(:expected_error) { 'theme_name cannot be blank' }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_hash is nil' do
      let(:theme_hash) { nil }
      let(:expected_error) { 'theme_hash cannot be nil' }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_hash is not a hash' do
      let(:theme_hash) { :not_a_hash }
      let(:expected_error) { /theme_hash must be a Hash/ }

      it_behaves_like 'an error is raised'
    end

    context 'when theme_hash is empty' do
      let(:theme_hash) { {} }
      let(:expected_error) { 'theme_hash cannot be empty' }

      it_behaves_like 'an error is raised'
    end
  end

  describe '#call' do
    context 'when the theme file does not exist' do
      it_behaves_like 'the color theme file does not exist'
      it_behaves_like 'the color theme file is created'
    end
  end

  describe '#call!' do
    subject(:writer_service_call) { writer_service.call! }

    context 'when the theme file already exists' do
      before do
        # This creates the file before our test.
        writer_service.call
      end

      let(:expected_error) { /Theme file already exists for theme "#{theme_name}"/ }

      it_behaves_like 'an error is raised'
    end

    context 'when the theme file does not exist' do
      it_behaves_like 'the color theme file does not exist'
      it_behaves_like 'the color theme file is created'
    end
  end
end
