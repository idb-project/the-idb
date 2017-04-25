FactoryGirl.define do
  factory :network do
    sequence(:name) { |n| "Network#{n}" }
    sequence(:address) { |n| "192.0.2.#{n}" }
  end
end
