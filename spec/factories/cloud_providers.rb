FactoryBot.define do
  factory :cloud_provider do
    sequence(:name) { |n| "CloudProvider_#{n}" }
  end
end
