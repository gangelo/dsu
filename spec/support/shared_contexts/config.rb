# frozen_string_literal: true

RSpec.shared_context 'with config' do

  before do
    mocked_default_dsu_options = Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS.dup
    mocked_default_dsu_options['entries_folder'] = entries_folder
    mocked_default_dsu_options['themes_folder'] = themes_folder
    stub_const('Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS', mocked_default_dsu_options)
  end
end

RSpec.configure do |config|
  config.include_context 'with config'
end
