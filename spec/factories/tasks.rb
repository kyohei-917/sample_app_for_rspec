FactoryBot.define do
  factory :task do
    sequence(:title, "title_1")
    content { "aiueoaiueo" }
    deadline { 10.years.ago }
    status { "todo" }
    user
  end
end