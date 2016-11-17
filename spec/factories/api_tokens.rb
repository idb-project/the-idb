FactoryGirl.define do
  factory :api_token do
    token	"deadbeef"
    name "general token"
    read	false
    write false
  end

  factory :api_token_r, class: ApiToken do
    token "dead"
    name "r-token"
    read true
    write false
  end

  factory :api_token_w, class: ApiToken do
    token "beef"
    name "w-token"
    read false
    write true
  end	
end
