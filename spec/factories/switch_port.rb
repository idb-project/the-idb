FactoryBot.define do
  factory :switch_port do
    number { 1 }
    nic
    switch
  end
end
