FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "MyLocation_#{n}" }
    level { 10 }
  end
end
