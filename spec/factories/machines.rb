FactoryBot.define do
  factory :machine do
    sequence(:fqdn) { |n| "fqdn-#{n}.example.com" }
    cores { 4 }
    announcement_deadline { nil }
  end
end
