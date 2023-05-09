# frozen_string_literal: true

# This shared context makes sure that the configuration entries_folder
# points to a temporary folder for all our tests
RSpec.shared_context 'with configuration' do
  before do
    stub_const('Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS', configuration_default_dsu_options)
  end

  # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
  let(:configuration_default_dsu_options) do
    {
      'entries_folder' => "#{Dir.tmpdir}/dsu/entries",
      'entries_file_name' => '%Y-%m-%d.json'
    }
  end
  # rubocop:enable Style/StringHashKeys
end

RSpec.configure do |config|
  config.include_context 'with configuration'
end
