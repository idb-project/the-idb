FactoryBot.define do
  factory :inventory do
    sequence(:inventory_number) { |n| "Inventory_#{n}" }
  end
end
