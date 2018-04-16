FactoryGirl.define do
  factory :virtual_machine, class: VirtualMachine do
    sequence(:fqdn) { |n| "fqdn-#{n}.vm.example.com" }
    vmhost ""
  end
end
