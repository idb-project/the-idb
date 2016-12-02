FactoryGirl.define do
  factory :machine do
    sequence(:fqdn) { |n| "fqdn-#{n}.example.com" }
    cores 4
    backup_brand 2
  end
end
