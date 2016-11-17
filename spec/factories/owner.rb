FactoryGirl.define do
  factory :owner do
    sequence(:name) { |n| "Owner#{n}" }
    sequence(:nickname) { |n| "Nickname#{n}" }
  end
end
