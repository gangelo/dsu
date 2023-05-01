FactoryBot.define do
  factory :entry, class: 'Dsu::Support::Entry' do
    uuid { SecureRandom.uuid[0..7] }
    description { FFaker::Lorem.words(rand(2..80)).join(' ')[0...80] }
    long_description {}
    order { 0 }
    time {}
    version { Dsu::Support::EntriesVersion::ENTRIES_VERSION }

    trait :invalid do
      description { nil }
    end

    initialize_with do
      new(uuid: uuid,
        description: description,
        long_description: long_description,
        order: order,
        time: time,
        version: version)
    end
  end
end
