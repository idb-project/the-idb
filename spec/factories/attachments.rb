FactoryGirl.define do
  factory :attachment do
    attachment File.new(Rails.root + 'spec/factories/files/rspec-logo.png') 
  end
end
