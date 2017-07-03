FactoryGirl.define do
  factory :switch do
    sequence(:fqdn) { |n| "switch-#{n}.example.com" }
  end
end
