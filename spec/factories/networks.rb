FactoryBot.define do
  factory :network do
    sequence(:name) { |n| "Network_#{n}" }
    sequence(:address) { |n| "192.0.2.#{n}" }
  end
end
