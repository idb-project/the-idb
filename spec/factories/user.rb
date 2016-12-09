FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "User#{n}" }
  end
end
