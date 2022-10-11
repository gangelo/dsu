# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.shared_context 'with entries data' do
  let(:stub_entries_version) do
    stub_const('Dsu::Support::EntriesVersion::ENTRIES_VERSION', 'v0.0.1')
  end

  let(:entries_version) { Dsu::Support::EntriesVersion::ENTRIES_VERSION }
  let(:entries_hash_with_sorted_entries) do
    entries_hash_sorted = entries_hash.dup
    entries_hash_sorted[:entries].sort! { |entry| entry[:order] }
    entries_hash_sorted
  end
  let(:entries_hash) do
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
  let(:entry_0_hash) do
    {
      order: 0,
      time: time_utc,
      description: '0 description',
      long_description: '0 long description',
      version: entries_version
    }
  end
  let(:entry_1_hash) do
    {
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
