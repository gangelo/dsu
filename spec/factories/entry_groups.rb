# frozen_string_literal: true

FactoryBot.define do
  factory :entry_group, class: 'Dsu::Models::EntryGroup' do
    transient do
      # Use this if you want to control the entries added
      # to this entry group. For example, if you need to
      # control the entry uuids or other attributes.
      entries { [] }
    end

    time { nil }

    # Use this trait if you want to simply add entries to
    # this entry group and do not care about the entry
    # attributes used.
    trait :with_entries do
      entries { build_list(:entry, 2) }
    end

    initialize_with do
      new(time: time, entries: entries)
    end

    after(:build) do |entry_group, evaluator|
      evaluator.entries&.each_with_index do |entry, index|
        raise 'Entry must be an instance of Dsu::Models::Entry' unless entry.is_a?(Dsu::Models::Entry)

        entry_group.entries[index] = entry.clone
      end
    end
  end
end
