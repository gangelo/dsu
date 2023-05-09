# frozen_string_literal: true

FactoryBot.define do
  factory :entry, class: 'Dsu::Models::Entry' do
    uuid { SecureRandom.uuid[0..7] }
    description { FFaker::Lorem.words(rand(2..80)).join(' ')[0...80] }

    trait :invalid do
      description { nil }
    end

    initialize_with do
      new(uuid: uuid, description: description)
    end
  end
end
