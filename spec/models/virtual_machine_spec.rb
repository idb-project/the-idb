require 'spec_helper'

describe VirtualMachine do
  before :each do
    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)
  end

  let(:attributes) do
    {
      fqdn: 'machine.example.com',
      owner: @owner
    }
  end

  let(:machine) { described_class.new(attributes) }

  describe 'hosted_on scope' do
    it 'returns all VMs for a Machine' do
      m = FactoryGirl.create(:machine)
      vm0 = FactoryGirl.create(:virtual_machine, vmhost: m.fqdn)
      vm1 = FactoryGirl.create(:virtual_machine, vmhost: m.fqdn)

      expect(VirtualMachine.hosted_on(m).size).to eq(2)
    end

    it 'returns all VMs for multiple Machines' do
      m0 = FactoryGirl.create(:machine, fqdn: "host0.example.org")
      m1 = FactoryGirl.create(:machine, fqdn: "host1.example.org")
      vm0 = FactoryGirl.create(:virtual_machine, vmhost: m0.fqdn)
      vm1 = FactoryGirl.create(:virtual_machine, vmhost: m1.fqdn)

      expect(VirtualMachine.hosted_on(Machine.where(fqdn: [m0.fqdn, m1.fqdn])).size).to eq(2)
    end
  end
end