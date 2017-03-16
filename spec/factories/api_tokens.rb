FactoryGirl.define do
  factory :api_token do
    sequence(:token) { |n| "token-#{n}" }
    sequence(:name) { |n| "token-name-#{n}" }
    read	false
    write false
  end

  factory :api_token_r, class: ApiToken do
    sequence(:token) { |n| "r-token-#{n}" }
    sequence(:name) { |n| "r-token-name-#{n}" }
    read true
    write false
  end

  factory :api_token_w, class: ApiToken do
    sequence(:token) { |n| "w-token-#{n}" }
    sequence(:name) { |n| "w-token-name-#{n}" }
    read false
    write true
  end	
end
