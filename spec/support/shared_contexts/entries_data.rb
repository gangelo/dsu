# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.shared_context 'with entries data' do
  let(:stub_entries_version) do
    stub_const('Dsu::Support::EntriesVersion::ENTRIES_VERSION', '0.0.1')
  end

  let(:entries_version) { Dsu::Support::EntriesVersion::ENTRIES_VERSION }
  # The hash equivalent of an EntryGroup model.
  let(:entry_group_hash) do
    {
      version: entries_version,
      time: time_utc,
      entries: entries_hash_array
    }
  end
  let(:entries_hash_array) do
    [
      entry_1_hash,
      entry_0_hash
    ]
  end
  # The hash equivalent of an Entry model.
  let(:entry_0_hash) do
    {
      uuid: '00000000',
      order: 0,
      time: time_utc,
      description: '0 description',
      long_description: '0 long description',
      version: entries_version
    }
  end
  let(:entry_1_hash) do
    {
      uuid: '11111111',
      order: 1,
      time: time_utc,
      description: '1 description',
      long_description: '1 long description',
      version: entries_version
    }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers

RSpec.configure do |config|
  config.include_context 'with entries data'
end
