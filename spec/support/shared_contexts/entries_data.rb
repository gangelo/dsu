# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.shared_context 'with entries data' do
  # The hash equivalent of an EntryGroup model.
  let(:entry_group_hash) do
    {
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
      description: '0 description'
    }
  end
  let(:entry_1_hash) do
    {
      uuid: '11111111',
      description: '1 description'
    }
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers

RSpec.configure do |config|
  config.include_context 'with entries data'
end
