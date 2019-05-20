require 'spec_helper'

describe VirtualMachine do
  before :each do
    @owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
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
      m = FactoryBot.create(:machine)
      vm0 = FactoryBot.create(:virtual_machine, vmhost: m.fqdn)
      vm1 = FactoryBot.create(:virtual_machine, vmhost: m.fqdn)

      expect(VirtualMachine.hosted_on(m).size).to eq(2)
    end

    it 'returns all VMs for multiple Machines' do
      m0 = FactoryBot.create(:machine, fqdn: "host0.example.org")
      m1 = FactoryBot.create(:machine, fqdn: "host1.example.org")
      vm0 = FactoryBot.create(:virtual_machine, vmhost: m0.fqdn)
      vm1 = FactoryBot.create(:virtual_machine, vmhost: m1.fqdn)

      expect(VirtualMachine.hosted_on(Machine.where(fqdn: [m0.fqdn, m1.fqdn])).size).to eq(2)
    end
  end
end