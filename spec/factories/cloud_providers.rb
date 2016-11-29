FactoryGirl.define do
  factory :cloud_provider do
    sequence(:name) { |n| "CloudProvider#{n}" }
  end
end
