FactoryBot.define do
  factory :entry_group, class: 'Dsu::Support::EntryGroup' do
    transient do
      # Use this if you want to control the entries added
      # to this entry group. For example, if you need to
      # control the entry uuids or other attributes.
      entries { [] }
    end

    time {}
    version { Dsu::Support::EntriesVersion::ENTRIES_VERSION }

    # Use this trait if you want to simply add entries to
    # this entry group and do not care about the entry
    # attributes used.
    trait :with_entries do
      entries { build_list(:entry, 2) }
    end

    initialize_with do
      new(time: time)
    end

    after(:build) do |entry_group, evaluator|
      evaluator.entries&.each do |entry|
        raise 'Entry must be an instance of Dsu::Support::Entry' unless entry.is_a?(Dsu::Support::Entry)

        entry_group.entries << entry.clone
      end
    end
  end
end
