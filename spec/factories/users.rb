FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "Test#{n}@example.com"}
    password { "password" }
    password_confirmation { "password" }
  end
end
