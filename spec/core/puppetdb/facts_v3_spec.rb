require 'spec_helper'

describe Puppetdb::FactsV3 do
  let(:hash) do
    {
      operatingsystem: 'Ubuntu',
      operatingsystemrelease: '12.04',
      architecture: 'amd64',
      memorysize_mb: 2000,
      blockdevices: 'hda,sda,sdb',
      blockdevice_sda_size: 2000000,
      processorcount: 4,
      uptime_seconds: 1234,
      interfaces: 'eth0,eth1,lo,Local_Area_Connection_2',
      ipaddress_eth0: '172.20.10.7',
      ipaddress6_eth0: '2001:67c:18e8::a',
      ipaddress_eth1: '10.0.0.1',
      ipaddress_local_area_connection_2: '10.1.2.3',
      ipaddress_lo: '127.0.0.1',
      macaddress: '6a:a8:6d:e0:a2:a7',
      macaddress_eth0: '6a:a8:6d:e0:a2:a6',
      macaddress_eth1: '3c:97:0e:40:06:be',
      netmask_eth0: '255.255.255.240',
      netmask_eth1: '255.255.255.0',
      netmask_lo: '255.0.0.0',
      is_virtual: false,
      serialnumber: '42Q6F5J',
      drac_domain: 'example.com',
      drac_ipaddress: '10.1.1.1',
      drac_macaddress: '8c:23:4e:41:06:be',
      drac_name: 'idrac-vmhost24',
      drac_netmask: '255.255.255.0',
      idb_unattended_upgrades_reboot: true,
      idb_pending_updates: 8
    }
  end

  let(:facts) { described_class.new(hash) }

  subject { facts }

  its(:operatingsystem) { should eq('Ubuntu') }
  its(:operatingsystemrelease) { should eq('12.04') }
  its(:architecture) { should eq('amd64') }
  its(:memorysize_mb) { should eq(2000) }
  its(:blockdevices) { should eq("hda,sda,sdb") }
  its(:processorcount) { should eq(4) }
  its(:uptime_seconds) { should eq(1234) }
  its(:is_virtual) { should be(false) }
  its(:serialnumber) { should eq('42Q6F5J') }
  its(:idb_unattended_upgrades_reboot) { should be(true) }
  its(:idb_pending_updates) { should eq(8) }

  describe '#missing?' do
    it 'returns false' do
      expect(facts.missing?).to eq(false)
    end

    context 'with no facts data' do
      it 'returns true' do
        expect(described_class.new({}).missing?).to eq(true)
      end
    end
  end

  describe '#virtual_machine?' do
    context 'with is_virtual=true' do
      before { hash[:is_virtual] = true }

      it 'returns true' do
        expect(facts.virtual_machine?).to eq(true)
      end
    end

    context 'with is_virtual=false' do
      before { hash[:is_virtual] = false }

      it 'returns false' do
        expect(facts.virtual_machine?).to eq(false)
      end
    end
  end

  context 'if interfaces is nil' do
    before do
      hash[:interfaces] = nil
      hash[:drac_name] = nil
    end

    it 'does not have any interfaces' do
      expect(facts.interfaces).to be_empty
    end
  end

  context 'without iDrac' do
    before { hash.delete(:drac_name) }

    it 'does not have an idrac interface' do
      expect(facts.interfaces).to_not have_key('idrac')
    end
  end

  context 'if serialnumber is "Not Specified"' do
    it 'returns nil' do
      hash[:serialnumber] = 'Not Specified'

      expect(facts.serialnumber).to be_nil
    end
  end

  context 'if serialnumber is "System Serial Number"' do
    it 'returns nil' do
      hash[:serialnumber] = 'System Serial Number'

      expect(facts.serialnumber).to be_nil
    end
  end

  describe 'eth0' do
    let(:eth0) { facts.interfaces['eth0'] }

    it 'has an ip address' do
      expect(eth0.ip_address.addr).to eq(hash[:ipaddress_eth0])
    end

    it 'has an ipv6 address' do
      expect(eth0.ip_address.addr_v6).to eq(hash[:ipaddress6_eth0])
    end

    it 'has a netmask' do
      expect(eth0.ip_address.netmask).to eq(hash[:netmask_eth0])
    end

    it 'has a mac address' do
      expect(eth0.mac).to eq(hash[:macaddress_eth0])
    end

    it 'has an address family' do
      expect(eth0.ip_address.family).to eq('inet')
    end
  end

  describe 'eth1' do
    let(:eth1) { facts.interfaces['eth1'] }

    it 'has an ip address' do
      expect(eth1.ip_address.addr).to eq(hash[:ipaddress_eth1])
    end

    it 'has a netmask' do
      expect(eth1.ip_address.netmask).to eq(hash[:netmask_eth1])
    end

    it 'has a mac address' do
      expect(eth1.mac).to eq(hash[:macaddress_eth1])
    end

    it 'has an address family' do
      expect(eth1.ip_address.family).to eq('inet')
    end
  end

  describe 'local_area_connection_2' do
    let(:lan) { facts.interfaces['Local_Area_Connection_2'] }

    it 'has an ip address' do
      expect(lan.ip_address.addr).to eq(hash[:ipaddress_local_area_connection_2])
    end

    it 'has a netmask' do
      expect(lan.ip_address.netmask).to eq(hash[:netmask_local_area_connection_2])
    end

    it 'has a mac address' do
      expect(lan.mac).to eq(hash[:macaddress])
    end

    it 'has an address family' do
      expect(lan.ip_address.family).to eq('inet')
    end
  end

  describe 'lo' do
    it 'does not have a lo interface' do
      expect(facts.interfaces['lo']).to be_nil
    end
  end

  describe 'iDrac' do
    let(:drac) { facts.interfaces['idrac'] }

    it 'has an ip address' do
      expect(drac.ip_address.addr).to eq(hash[:drac_ipaddress])
    end

    it 'has a netmask' do
      expect(drac.ip_address.netmask).to eq(hash[:drac_netmask])
    end

    it 'has a mac address' do
      expect(drac.mac).to eq(hash[:drac_macaddress])
    end

    it 'has an address family' do
      expect(drac.ip_address.family).to eq('inet')
    end
  end

  describe 'normalizations' do
    it 'downcases the mac addresses' do
      hash[:macaddress_eth0] = '6A:A8:6D:E0:A2:A6'

      expect(facts.interfaces['eth0'].mac).to eq('6a:a8:6d:e0:a2:a6')
    end

    it 'handles nil mac addresses' do
      hash[:macaddress_eth0] = nil
      hash[:macaddress] = nil

      expect(facts.interfaces['eth0'].mac).to be_nil
    end
  end

  describe 'windows fixups' do
    before do
      hash[:operatingsystem] = 'Windows'
    end

    context 'version 6.1.7601' do
      before do
        hash[:operatingsystemrelease] = '6.1.7601'
      end

      it 'sets the version to 7 SP1 / Server 2008 R2 SP1' do
        expect(facts.operatingsystemrelease).to eq('7 SP1 / Server 2008 R2 SP1')
      end
    end

    context 'version 6.1.7600' do
      before do
        hash[:operatingsystemrelease] = '6.1.7600'
      end

      it 'sets the version to 7 / Server 2008 R2' do
        expect(facts.operatingsystemrelease).to eq('7 / Server 2008 R2')
      end
    end
  end
end
