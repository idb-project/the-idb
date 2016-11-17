require 'spec_helper'

describe Nic do
  let(:nic) { described_class.new }
  let(:mac) { '02:15:e0:ec:01:(00-ff)' }

  before do
    nic.ip_address = IpAddress.new(addr: '10.0.0.1', netmask: '255.255.255.0', addr_v6: '2001:0db8:85a3:08d3:1319:8a2e:0370:7344', netmask_v6: '2001:0DB8:85a3:08D3:1319:8A2E:0370:7347/64')
  end

  describe 'downcased mac address' do
    it 'creates a downcased mac address' do
      nic.mac = '02:15:e0:ec:01:(00-ff)'.upcase
      nic.save!

      expect(nic.mac).to eq('02:15:e0:ec:01:(00-ff)'.downcase)
    end

    context 'when mac is nil' do
      it 'does not try to downcase it' do
        nic.mac = nil

        expect { nic.save! }.to_not raise_error
      end
    end
  end

  it 'accepts a wrongly formatted mac address' do
    nic.mac = 'foo'

    expect(nic).to be_valid
  end

  it 'accepts a missing mac address' do
    nic.mac = nil

    expect(nic).to be_valid
  end

  it 'accepts a blank mac address' do
    nic.mac = ''

    expect(nic).to be_valid
  end

  it 'saves a blank mac address to nil' do
    nic.mac = ''
    nic.save!

    expect(Nic.find(nic.id).mac).to be_nil
  end

  it 'allows a duplicate mac address' do
    described_class.create!(name: 'eth0', machine_id: 1, mac: mac)
    described_class.create!(name: 'eth0', machine_id: 2, mac: mac)

    expect(Nic.count).to be(2)
  end

  it 'does not allow the same name and machine twice' do
    expect {
      described_class.create!(name: 'eth0', machine_id: 1, mac: mac)
      described_class.create!(name: 'eth0', machine_id: 1, mac: mac)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe '#ipv4addr' do
    it 'returns the ip address' do
      expect(nic.ipv4addr).to eq('10.0.0.1')
    end

    context 'without ip address' do
      before { nic.ip_address = nil }

      it 'returns nil' do
        expect(nic.ipv4addr).to be_nil
      end
    end
  end

  describe '#ipv6addr' do
    it 'returns the ipv6 address' do
      expect(nic.ipv6addr).to eq('2001:0db8:85a3:08d3:1319:8a2e:0370:7344')
    end

    context 'without ip address' do
      before { nic.ip_address = nil }

      it 'returns nil' do
        expect(nic.ipv6addr).to be_nil
      end
    end
  end

  describe '#ipv4mask' do
    it 'returns the netmask' do
      expect(nic.ipv4mask).to eq('255.255.255.0')
    end

    context 'without ip address' do
      before { nic.ip_address = nil }

      it 'returns nil' do
        expect(nic.ipv4mask).to be_nil
      end
    end
  end

  describe '#ipv6mask' do
    it 'returns the netmask' do
      expect(nic.ipv6mask).to eq('2001:0DB8:85a3:08D3:1319:8A2E:0370:7347/64')
    end

    context 'without ip address' do
      before { nic.ip_address = nil }

      it 'returns nil' do
        expect(nic.ipv6mask).to be_nil
      end
    end
  end
end
