FactoryBot.define do
  factory :maintenance_announcement do
    begin_date { "2018-02-26 15:52:54" }
    end_date { "2018-02-27 15:52:54" }
    reason { "MyText" }
    impact { "MyText" }
    maintenance_template { nil }
  end
end
