FactoryBot.define do
  factory :owner do
    sequence(:name) { |n| "Owner_#{n}" }
    sequence(:nickname) { |n| "Nickname#{n}" }
    announcement_contact { nil }
  end
end
