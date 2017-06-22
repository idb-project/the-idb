FactoryGirl.define do
  factory :nic do
    sequence(:name) { |n| "Nic_#{n}" }
    mac "aa:bb:cc:dd:ee:ff"
    machine
  end
end
