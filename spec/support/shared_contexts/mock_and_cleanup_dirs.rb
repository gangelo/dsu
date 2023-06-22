# frozen_string_literal: true

RSpec.shared_context 'when dir mock and cleanup is needed' do
  before do
    # Mock Dir.home and Dir.tmpdir to return the temporary directories
    allow(Dir).to receive(:home).and_return(temp_folder)
    allow(Dir).to receive(:tmpdir).and_return(temp_folder)
    allow(Tempfile).to receive(:new).with('dsu').and_return(temp_file)

    theme_name = Dsu::Models::ColorTheme::DEFAULT_THEME_NAME
    theme_hash = Dsu::Models::ColorTheme::DEFAULT_THEME
    Dsu::Models::ColorTheme.new(theme_name: theme_name, theme_hash: theme_hash).save!

    Dsu::Models::Configuration.instance.load(config_hash: Dsu::Models::Configuration::DEFAULT_CONFIGURATION).save!
  end

  after do
    # Clean up the files and directories created within the temporary directory.
    FileUtils.rm_rf(File.join(temp_folder, 'dsu'))
  end

  let(:temp_folder) { Dir.tmpdir }
  let(:temp_file) { Tempfile.new('dsu', temp_folder) }
end

RSpec.configure do |config|
  config.include_context 'when dir mock and cleanup is needed'
end
