# frozen_string_literal: true

RSpec.shared_context 'with config' do
  before do
    mocked_default_dsu_options = Dsu::Models::Configuration::DEFAULT_CONFIGURATION.dup
    mocked_default_dsu_options['entries_folder'] = entries_folder
    mocked_default_dsu_options['themes_folder'] = themes_folder
    stub_const('Dsu::Models::Configuration::DEFAULT_CONFIGURATION', mocked_default_dsu_options)
  end
end

RSpec.configure do |config|
  config.include_context 'with config'
end
