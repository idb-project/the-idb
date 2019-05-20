FactoryBot.define do
  factory :machine_alias do
    sequence(:name) { |n| "alias-#{n}.example.org" }
    machine
  end
end