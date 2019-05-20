FactoryBot.define do
  factory :inventory_status do
    sequence(:name) { |n| "my_status_#{n}" }
  end
end
