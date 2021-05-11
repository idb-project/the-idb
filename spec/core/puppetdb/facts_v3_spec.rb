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
      networking: {:interfaces=>{"lo"=>{"ip"=>"127.0.0.1", "bindings6"=>[{"address"=>"::1", "netmask"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "network"=>"::1"}], "mtu"=>65536, "bindings"=>[{"address"=>"127.0.0.1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0"}], "network6"=>"::1", "netmask6"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "ip6"=>"::1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0", "scope6"=>"host"}, "eth0"=>{"ip"=>"172.20.10.7", "bindings6"=>[{"address"=>"172.20.10.7v6", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"172.20.10.7", "netmask"=>"255.255.255.240", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"6a:a8:6d:e0:a2:a6"}, "eth1"=>{"ip"=>"10.0.0.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"10.0.0.1", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:be"}, "Ethernet 2"=>{"ip"=>"127.0.1.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"127.0.1.1", "netmask"=>"255.255.0.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:b2"}}, "ip"=>"10.10.0.9", "primary"=>"eth0", "mtu"=>1500, "network6"=>"2001:37f:19f8:2::", "hostname"=>"myfqdn", "dhcp"=>"10.10.0.66", "fqdn"=>"myfqdn.example.com", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "domain"=>"mydomain.local", "scope6"=>"global", "mac"=>"ce:cc:c0:07:01:d3"},
      is_virtual: false,
      serialnumber: '42Q6F5J',
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
      hash[:networking][:interfaces] = nil
    end

    it 'does not have any interfaces' do
      expect(facts.interfaces).to be_empty
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
    let(:eth0) { facts.interfaces["172.20.10.7"] }

    it 'has an ip address' do
      expect(eth0.ip_address.addr).to eq(hash[:networking][:interfaces]["eth0"]["bindings"].first["address"])
    end

    it 'has an ipv6 address' do
      expect(eth0.ip_address.addr_v6).to eq(hash[:networking][:interfaces]["eth0"]["bindings6"].first["address"])
    end

    it 'has a netmask' do
      expect(eth0.ip_address.netmask).to eq(hash[:networking][:interfaces]["eth0"]["bindings"].first["netmask"])
    end

    it 'has a mac address' do
      expect(eth0.mac).to eq(hash[:networking][:interfaces]["eth0"]["mac"])
    end

    it 'has an address family' do
      expect(eth0.ip_address.family).to eq('inet')
    end
  end

  describe 'eth1' do
    let(:eth1) { facts.interfaces["10.0.0.1"] }

    it 'has an ip address' do
      expect(eth1.ip_address.addr).to eq(hash[:networking][:interfaces]["eth1"]["bindings"].first["address"])
    end
  end

  describe 'normalizations' do
    it 'downcases the mac addresses' do
      hash[:networking][:interfaces]["eth0"]["mac"] = '6A:A8:6D:E0:A2:A6'

      expect(facts.interfaces['172.20.10.7'].mac).to eq('6a:a8:6d:e0:a2:a6')
    end

    it 'handles nil mac addresses' do
      hash[:networking][:interfaces]["eth0"]["mac"] = nil

      expect(facts.interfaces['172.20.10.7'].mac).to be_nil
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
