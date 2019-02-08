# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Internet.username }
    email { Faker::Internet.safe_email }
    password { Faker::Internet.password }
    admin { false }

    factory :admin do
      name { Faker::Internet.username('admin') }
      admin { true }
    end
  end

  factory :text do
    title { Faker::Lorem.words(2..4).join(' ') }
    filetype { '.txt' }
    body { Faker::Lorem.paragraph(2) }
    user
  end
end
