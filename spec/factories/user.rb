FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "User_#{n}" }
  end
end
