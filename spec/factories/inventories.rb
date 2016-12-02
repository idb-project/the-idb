FactoryGirl.define do
  factory :inventory do
    sequence(:inventory_number) { |n| "Inventory#{n}" }
  end
end
