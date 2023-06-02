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
        Dsu::Models::ColorTheme::DEFAULT_THEME.merge({ description: 'Test theme description' })
      end

      it 'returns the loaded color theme' do
        expect(loader_service.call).to eq(Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash))
      end
    end

    context 'when the color theme file exists and migrations are needed' do
      before do
        create_default_color_theme!
        stub_const('Dsu::Models::ColorTheme::DEFAULT_THEME', mocked_default_color_theme)

        # Mock the color theme migration service so that we can make sure it is
        # called to migrate the color themes if the color theme version is not
        # current.
        allow(Dsu::Migration::ColorThemeMigratorService).to receive(:new).and_return(mocked_migration_service)
        allow(mocked_migration_service).to receive(:call)
      end

      let(:mocked_migration_service) { instance_double(Dsu::Migration::ColorThemeMigratorService) }

      # These options represent (for example) a user updates this gem, the default
      # configuration has changed to include a more recent version.
      let(:mocked_default_color_theme) do
        Dsu::Models::ColorTheme::DEFAULT_THEME.dup.tap do |default_color_theme|
          default_color_theme[:version] = default_color_theme[:version].gsub(/\d+\.\d+\.\d+/, '100.0.0')
        end
      end
      let(:theme_name) { Dsu::Models::ColorTheme.default.theme_name }
      let(:expected_color_theme) do
        Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: mocked_default_color_theme)
      end

      # TODO: This test won't pass until the migration service is implemented.
      it 'runs migrations for color themes' do
        loader_service.call
        expect(mocked_migration_service).to have_received(:call).once
      end
    end
  end
end
