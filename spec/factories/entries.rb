# frozen_string_literal: true

FactoryBot.define do
  factory :entry, class: 'Dsu::Models::Entry' do
    description { FFaker::Lorem.words(rand(2..80)).join(' ')[0...80] }

    trait :invalid do
      description { '' }
    end

    initialize_with do
      new(description: description)
    end
  end
end
