FactoryBot.define do
  factory :k_cloud_report do
    sequence(:ip) { |n| "192.168.0.#{n}" }
    sequence(:usercount) { |n| n }
  end
end
