require 'spec_helper'

describe EditableMachineForm do
  let(:machine) do
    owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(owner.users.first)
    Machine.new(fqdn: 'box.example.com', owner: owner)
  end

  let(:attributes) do
    ActionController::Parameters.new(
      backup_type: 1,
      auto_update: false,
      arch: 'i386',
      ram: 1024,
      cores: 2,
      serialnumber: '123',
      vmhost: 'foo.example.com',
      os: 'Ubuntu',
      os_release: '12.04',
      nics: [
        {
          name: 'eth3',
          mac: '3c:97:5e:40:16:ae',
          ip_address: {
            addr: '10.0.0.1',
            netmask: '255.255.255.0',
            addr_v6: '2001:0DB8:85a3:08D3:1319:8A2E:0370:7347',
            netmask_v6: '2001:0DB8:85a3:08D3:1319:8A2E:0370:7347/64'
          }
        }
      ],
      aliases: [
        {
          name: 'alias1a'
        }
      ]
    )
  end

  let(:form) { described_class.new(machine) }

  describe '#update' do
    before { machine.save! }

    it 'returns empty Hash if nothing changed' do
      expect(form.update(ActionController::Parameters.new)).to eq({})
    end

    it 'returns nil on errors' do
      expect(form.update(ActionController::Parameters.new(fqdn: -1))).to be_nil
    end

    it 'returns a hash with changed attributes on attribute changes' do
      expect(form.update(ActionController::Parameters.new(os: "abc")).keys).to eq(["os"])
    end

    it 'updates the backup_type' do
      form.update(attributes)

      expect(machine.backup_type).to eq(1)
    end

    it 'updates the auto_update' do
      form.update(attributes)

      expect(machine.auto_update).to eq(false)
    end

    it 'updates the arch' do
      form.update(attributes)

      expect(machine.arch).to eq('i386')
    end

    it 'updates the ram' do
      form.update(attributes)

      expect(machine.ram).to eq(1024)
    end

    it 'updates the cores' do
      form.update(attributes)

      expect(machine.cores).to eq(2)
    end

    it 'updates the serialnumber' do
      form.update(attributes)

      expect(machine.serialnumber).to eq('123')
    end

    it 'updates the vmhost' do
      form.update(attributes)

      expect(machine.vmhost).to eq('foo.example.com')
    end

    it 'updates the os' do
      form.update(attributes)

      expect(machine.os).to eq('Ubuntu')
    end

    it 'updates os release' do
      form.update(attributes)

      expect(machine.os_release).to eq('12.04')
    end

    it 'adds a nic' do
      form.update(attributes)

      expect(machine.nics.first.name).to eq('eth3')
      expect(machine.nics.first.mac).to eq('3c:97:5e:40:16:ae')
      expect(machine.nics.first.ipv4addr).to eq('10.0.0.1')
      expect(machine.nics.first.ipv4mask).to eq('255.255.255.0')
      expect(machine.nics.first.ipv6addr).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:7347')
      expect(machine.nics.first.ipv6mask).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:7347/64')
      expect(machine.nics.first.ip_address.family).to eq('inet')
    end

    it 'updates a nic' do
      form.update(attributes)

      expect(machine.nics.first.ipv4addr).to eq('10.0.0.1')
      expect(machine.nics.first.name).to eq('eth3')

      attributes[:nics].first[:ip_address][:addr] = '127.0.0.1'
      attributes[:nics].first[:ip_address][:addr_v6] = '2001:0DB8:85a3:08D3:1319:8A2E:0370:4711'
      attributes[:nics].first[:name] = 'eth3-new'

      form.update(attributes)

      expect(machine.nics.first.ipv4addr).to eq('127.0.0.1')
      expect(machine.nics.first.ipv6addr).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:4711')
      expect(machine.nics.first.name).to eq('eth3-new')
    end

    describe 'invalid multiple nics' do
      it 'errors on nics with same name' do
        attrs = attributes.clone
        attrs[:nics] << {
          name: 'invalid',
          mac: 'aa:bb:cc:dd:ee:ff',
          ip_address: {
            addr: '10.0.0.1',
            netmask: '255.255.255.0'
          }
        }
        attrs[:nics] << {
          name: 'invalid',
          mac: 'ab:bb:cc:dd:ee:ff',
          ip_address: {
            addr: '10.0.0.2',
            netmask: '255.255.255.0'
          }
        }
        expect(form.update(attrs)).to eq(false)
      end
    end

    describe 'multiple nics' do
      before do
        attributes[:nics] << {
          name: 'eth4',
          mac: '3c:97:5e:40:16:a1',
          ip_address: {
            addr: '10.0.0.2',
            netmask: '255.255.255.0',
            addr_v6: '2001:0DB8:85a3:08D3:1319:8A2E:0370:1234',
            netmask_v6: '2001:0DB8:85a3:08D3:1319:8A2E:0370:1234/64'
          }
        }
      end

      it 'can add more than one nic' do
        form.update(attributes)

        expect(machine.nics.first.name).to eq('eth3')
        expect(machine.nics.first.mac).to eq('3c:97:5e:40:16:ae')
        expect(machine.nics.first.ipv4addr).to eq('10.0.0.1')
        expect(machine.nics.first.ipv4mask).to eq('255.255.255.0')
        expect(machine.nics.first.ipv6addr).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:7347')
        expect(machine.nics.first.ipv6mask).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:7347/64')
        expect(machine.nics.first.ip_address.family).to eq('inet')

        expect(machine.nics.last.name).to eq('eth4')
        expect(machine.nics.last.mac).to eq('3c:97:5e:40:16:a1')
        expect(machine.nics.last.ipv4addr).to eq('10.0.0.2')
        expect(machine.nics.last.ipv4mask).to eq('255.255.255.0')
        expect(machine.nics.last.ipv6addr).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:1234')
        expect(machine.nics.last.ipv6mask).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:1234/64')
        expect(machine.nics.last.ip_address.family).to eq('inet')
      end

      it 'removes nics' do
        form.update(attributes)

        attributes[:nics].first[:remove] = true

        form.update(attributes)

        machine.reload

        expect(machine.nics.size).to eq(1)
      end
    end

    it 'adds an alias' do
      form.update(attributes)

      expect(machine.aliases.first.name).to eq('alias1a')
    end

    it 'updates an alias' do
      form.update(attributes.dup)

      expect(machine.aliases.first.name).to eq('alias1a')

      attributes[:aliases].first[:name] = 'alias1b'

      described_class.new(Machine.first).update(attributes)

      m = Machine.find(machine.id)

      expect(m.aliases.last.name).to eq('alias1b')
    end

    describe 'multiple aliases' do
      before do
        attributes[:aliases] << {
          name: 'alias2'
        }
      end

      it 'can add more than one alias' do
        form.update(attributes)

        expect(machine.aliases.first.name).to eq('alias1a')

        expect(machine.aliases.last.name).to eq('alias2')
      end

      it 'removes aliases' do
        form.update(attributes)

        attributes[:aliases].first[:remove] = true

        form.update(attributes)

        machine.reload

        expect(machine.aliases.size).to eq(1)
      end
    end
  end

  describe '#arch_list' do
    it 'returns a list of architectures' do
      expect(form.arch_list).to eq(%w(amd64 i386))
    end
  end

  describe '#core_collection' do
    it 'returns a list of even core numbers' do
      expect(form.core_collection[0, 4]).to eq([1, 2, 4, 6])
    end
  end

  describe '#nic_for' do
    it 'returns a NIC object if valid params given' do
      data = {:name=>"eth5"}
      expect(form.nic_for(data)).to_not be_nil
    end

    it 'returns nil if invalid or insufficient params given' do
      data = {}
      expect(form.nic_for(data)).to be_nil
    end
  end
end
