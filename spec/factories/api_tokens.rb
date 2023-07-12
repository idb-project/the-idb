FactoryBot.define do
  factory :api_token do
    sequence(:token) { |n| "token-#{n}" }
    sequence(:name) { |n| "token-name-#{n}" }
    read { false }
    write { false }
    post_reports { false }
    post_logs { false }
  end

  factory :api_token_r, class: ApiToken do
    sequence(:token) { |n| "r-token-#{n}" }
    sequence(:name) { |n| "r-token-name-#{n}" }
    read { true }
    write { false }
    post_reports { false }
    post_logs { false }
  end

  factory :api_token_w, class: ApiToken do
    sequence(:token) { |n| "w-token-#{n}" }
    sequence(:name) { |n| "w-token-name-#{n}" }
    read { false }
    write { true }
    post_reports { false }
    post_logs { false }
  end	

  factory :api_token_rw, class: ApiToken do
    sequence(:token) { |n| "rw-token-#{n}" }
    sequence(:name) { |n| "rw-token-name-#{n}" }
    read { true }
    write { true }
    post_reports { false }
    post_logs { false }
  end

  factory :api_token_pr, class: ApiToken do
    sequence(:token) { |n| "pr-token-#{n}" }
    sequence(:name) { |n| "pr-token-name-#{n}" }
    read { false }
    write { false }
    post_reports { true }
    post_logs { false }
  end

  factory :api_token_pl, class: ApiToken do
    sequence(:token) { |n| "pr-token-#{n}" }
    sequence(:name) { |n| "pr-token-name-#{n}" }
    read { false }
    write { false }
    post_reports { false }
    post_logs { true }
  end
end
