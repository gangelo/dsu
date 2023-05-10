# frozen_string_literal: true

# This shared context makes sure that the configuration entries_folder
# points to a temporary folder for all our tests
RSpec.shared_context 'with configuration' do
  before do
    stub_default_dsu_options
  end

  # Override this in your tests if you want to use a different folder or stop
  # stubbing the default options.
  let(:stub_default_dsu_options) do
    stub_const('Dsu::Support::Configuration::DEFAULT_DSU_OPTIONS', mocked_default_dsu_options)
  end

  # rubocop:disable Style/StringHashKeys - YAML writing/loading necessitates this
  let(:mocked_default_dsu_options) do
    {
      'editor' => 'nano',
      'entries_display_order' => 'desc',
      'entries_folder' => "#{Dir.tmpdir}/dsu/entries",
      'entries_file_name' => '%Y-%m-%d.json'
    }
  end
  # rubocop:enable Style/StringHashKeys
end

RSpec.configure do |config|
  config.include_context 'with configuration'
end
