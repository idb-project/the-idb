require 'spec_helper'

describe MachineUpdateService do
  describe '.update_from_facts' do
    let(:facts) do
      Puppetdb::Facts.new(
        networking: {"interfaces"=>{"lo"=>{"ip"=>"127.0.0.1", "bindings6"=>[{"address"=>"::1", "netmask"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "network"=>"::1"}], "mtu"=>65536, "bindings"=>[{"address"=>"127.0.0.1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0"}], "network6"=>"::1", "netmask6"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "ip6"=>"::1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0", "scope6"=>"host"}, "eth0"=>{"ip"=>"172.20.10.7", "bindings6"=>[{"address"=>"172.20.10.7v6", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"172.20.10.7", "netmask"=>"255.255.255.240", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"6a:a8:6d:e0:a2:a6"}, "eth1"=>{"ip"=>"10.0.0.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"10.0.0.1", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:be"}, "Ethernet 2"=>{"ip"=>"127.0.1.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"127.0.1.1", "netmask"=>"255.255.0.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:b2"}}, "ip"=>"10.10.0.9", "primary"=>"eth0", "mtu"=>1500, "network6"=>"2001:37f:19f8:2::", "hostname"=>"myfqdn", "dhcp"=>"10.10.0.66", "fqdn"=>"myfqdn.example.com", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "domain"=>"mydomain.local", "scope6"=>"global", "mac"=>"ce:cc:c0:07:01:d3"},
        is_virtual: false,
        serialnumber: '42Q6F5J',
        memorysize_mb: '12018.26',
        blockdevices: 'hda,sda',
        blockdevice_hda_size: 2000000,
        blockdevice_sda_size: 1000000,
        operatingsystem: 'Windows',
        lsbdistrelease: '2012 R1'
      )
    end

    let(:factsv4) do
      Puppetdb::FactsV4.new(
        networking: {"interfaces"=>{"lo"=>{"ip"=>"127.0.0.1", "bindings6"=>[{"address"=>"::1", "netmask"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "network"=>"::1"}], "mtu"=>65536, "bindings"=>[{"address"=>"127.0.0.1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0"}], "network6"=>"::1", "netmask6"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "ip6"=>"::1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0", "scope6"=>"host"}, "eth0"=>{"ip"=>"172.20.10.7", "bindings6"=>[{"address"=>"172.20.10.7v6", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"172.20.10.7", "netmask"=>"255.255.255.240", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"6a:a8:6d:e0:a2:a6"}, "eth1"=>{"ip"=>"10.0.0.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"10.0.0.1", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:be"}, "Ethernet 2"=>{"ip"=>"127.0.1.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"127.0.1.1", "netmask"=>"255.255.0.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:b2"}}, "ip"=>"10.10.0.9", "primary"=>"eth0", "mtu"=>1500, "network6"=>"2001:37f:19f8:2::", "hostname"=>"myfqdn", "dhcp"=>"10.10.0.66", "fqdn"=>"myfqdn.example.com", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "domain"=>"mydomain.local", "scope6"=>"global", "mac"=>"ce:cc:c0:07:01:d3"},
        is_virtual: false,
        serialnumber: '42Q6F5J',
        memorysize_mb: '12018.26',
        blockdevices: 'hda,sda',
        blockdevice_hda_size: 2000000,
        blockdevice_sda_size: 1000000,
        operatingsystem: 'Windows',
        operatingsystemrelease: '2012 R2'
      )
    end

    let(:factsUCS) do
      Puppetdb::FactsV4.new(
        networking: {"interfaces"=>{"lo"=>{"ip"=>"127.0.0.1", "bindings6"=>[{"address"=>"::1", "netmask"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "network"=>"::1"}], "mtu"=>65536, "bindings"=>[{"address"=>"127.0.0.1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0"}], "network6"=>"::1", "netmask6"=>"ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff", "ip6"=>"::1", "netmask"=>"255.0.0.0", "network"=>"127.0.0.0", "scope6"=>"host"}, "eth0"=>{"ip"=>"172.20.10.7", "bindings6"=>[{"address"=>"172.20.10.7v6", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"172.20.10.7", "netmask"=>"255.255.255.240", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"6a:a8:6d:e0:a2:a6"}, "eth1"=>{"ip"=>"10.0.0.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"10.0.0.1", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:be"}, "Ethernet 2"=>{"ip"=>"127.0.1.1", "bindings6"=>[{"address"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"2001:37f:19f8:2::"}, {"address"=>"fe80::cccc:c0ff:fe07:1d3", "netmask"=>"ffff:ffff:ffff:ffff::", "network"=>"fe80::"}], "mtu"=>1500, "bindings"=>[{"address"=>"127.0.1.1", "netmask"=>"255.255.0.0", "network"=>"10.10.0.0"}], "network6"=>"2001:37f:19f8:2::", "dhcp"=>"10.10.0.66", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "scope6"=>"global", "mac"=>"3c:97:0e:40:06:b2"}}, "ip"=>"10.10.0.9", "primary"=>"eth0", "mtu"=>1500, "network6"=>"2001:37f:19f8:2::", "hostname"=>"myfqdn", "dhcp"=>"10.10.0.66", "fqdn"=>"myfqdn.example.com", "netmask6"=>"ffff:ffff:ffff:ffff::", "ip6"=>"2001:37f:19f8:2:cccc:c0ff:fe07:1d3", "netmask"=>"255.255.255.0", "network"=>"10.10.0.0", "domain"=>"mydomain.local", "scope6"=>"global", "mac"=>"ce:cc:c0:07:01:d3"},
        is_virtual: false,
        serialnumber: '42Q6F5J',
        memorysize_mb: '12018.26',
        blockdevices: 'hda,sda',
        blockdevice_hda_size: 2000000,
        blockdevice_sda_size: 1000000,
        operatingsystem: 'Windows',
        operatingsystemrelease: '2012 R2',
        ucs_version: '5.0-2'
      )
    end

    let(:machine) do
      current_user = FactoryBot.create(:user, admin: true)
      owner = FactoryBot.create(:owner, users: [current_user])
      allow(User).to receive(:current).and_return(current_user)
      machine = FactoryBot.create(:machine, fqdn: 'test.example.com', owner: owner)
    end

    before do
      allow(Puppetdb::FactsV3).to receive(:for).and_return(facts)
      allow(Puppetdb::FactsV3).to receive(:raw_data).and_return(facts.to_s)
      allow(Puppetdb::FactsV4).to receive(:for).and_return(factsv4)
      allow(Puppetdb::FactsV4).to receive(:raw_data).and_return(factsv4.to_s)
      @url = "https://puppetdb.example.com"
    end

    # it 'sets the device type' do
    #   described_class.update_from_facts(machine,  @url)

    #   expect(machine.device_type_id).to_not be_nil
    # end

    it 'sets the device type' do
        fqdn = machine.fqdn
        facts["is_virtual"] = true
        allow(Puppetdb::Facts).to receive(:for_node).and_return(facts)
        described_class.update_from_facts(machine, @url)
        machine = Machine.find_by_fqdn(fqdn)
        expect(machine).to be_a VirtualMachine
    end


    it 'sets the serialnumber' do
      described_class.update_from_facts(machine,  @url)

      expect(machine.serialnumber).to eq('42Q6F5J')
    end

    it 'sets the os' do
      described_class.update_from_facts(machine,  @url)

      expect(machine.os).to eq('Windows')
    end

    it 'sets the os_release' do
      described_class.update_from_facts(machine,  @url)

      expect(machine.os_release).to eq('2012 R1')
    end

    it 'sets the os from v4 facts' do
      described_class.update_from_facts(machine,  @url, "v4")

      expect(machine.os).to eq('Windows')
    end

    it 'sets the os_release from v4 facts' do
      described_class.update_from_facts(machine,  @url, "v4")

      expect(machine.os_release).to eq('2012 R2')
    end

    it 'sets the os from v4 facts for UCS machines' do
      allow(Puppetdb::FactsV4).to receive(:for).and_return(factsUCS)
      allow(Puppetdb::FactsV4).to receive(:raw_data).and_return(factsUCS.to_s)

      described_class.update_from_facts(machine,  @url, "v4")

      expect(machine.os).to eq('UCS')
    end

    it 'sets the os_release from v4 facts for UCS machines' do
      allow(Puppetdb::FactsV4).to receive(:for).and_return(factsUCS)
      allow(Puppetdb::FactsV4).to receive(:raw_data).and_return(factsUCS.to_s)

      described_class.update_from_facts(machine,  @url, "v4")

      expect(machine.os_release).to eq('5.0-2')
    end

    context 'retrieve the installed RAM' do
      it 'sets the RAM' do
        described_class.update_from_facts(machine, @url)

        expect(machine.ram).to eq(12018)
      end

      it 'sets the RAM from v4 facts' do
        described_class.update_from_facts(machine, @url, "v4")

        expect(machine.ram).to eq(12018)
      end

      it 'sets the RAM from v4 facts, written in GB' do
        factsv4["memorysize"] = "120GB"
        factsv4["memorysize_mb"] = nil
        allow(Puppetdb::FactsV4).to receive(:for_node).and_return(factsv4)
        described_class.update_from_facts(machine, @url, "v4")

        expect(machine.ram).to eq(122880)
      end
    end

    it 'sets the auto_update flag to true' do
      described_class.update_from_facts(machine, @url)

      expect(machine.auto_update).to eq(true)
    end

    context 'when no fact can be found' do
      before { allow(facts).to receive(:missing?).and_return(true) }

      it 'does not set auto_update to true' do
        described_class.update_from_facts(machine, @url)

        expect(machine.auto_update).to eq(false)
      end
    end

    describe 'interfaces' do
      context 'without existing interfaces' do
        before do
          described_class.update_from_facts(machine, @url)
        end

        it 'skips interfaces without an ip address' do
          nic = machine.nics.find {|n| n.name == 'eth2' }

          expect(nic).to be_nil
        end

        describe 'eth0 interface' do
          let(:nic) { machine.nics.find {|n| n.name == 'eth0' } }

          it 'sets the mac address' do
            expect(nic.mac).to eq('6a:a8:6d:e0:a2:a6')
          end

          it 'sets the ip address' do
            expect(nic.ip_address.addr).to eq('172.20.10.7')
          end

          it 'sets the netmask' do
            expect(nic.ip_address.netmask).to eq('255.255.255.240')
          end
        end

        describe 'eth1 interface' do
          let(:nic) { machine.nics.find {|n| n.name == 'eth1' } }

          it 'sets the mac address' do
            expect(nic.mac).to eq('3c:97:0e:40:06:be')
          end

          it 'sets the ip address' do
            expect(nic.ip_address.addr).to eq('10.0.0.1')
          end

          it 'sets the netmask' do
            expect(nic.ip_address.netmask).to eq('255.255.255.0')
          end
        end

        describe 'Ethernet 2 interface' do
          let(:nic) { machine.nics.find {|n| n.name == 'Ethernet 2' } }

          it 'sets the mac address' do
            expect(nic.mac).to eq('3c:97:0e:40:06:b2')
          end

          it 'sets the ip address' do
            expect(nic.ip_address.addr).to eq('127.0.1.1')
          end

          it 'sets the netmask' do
            expect(nic.ip_address.netmask).to eq('255.255.0.0')
          end
        end
      end

      context 'with existing nic objects' do
        before do
          nic = Nic.new(name: 'eth0', mac: 'aa:aa:aa:aa:aa:aa')
          nic.ip_address = IpAddress.new(addr: '1.1.1.1', netmask: '0.0.0.0', family: 'a')

          nic2 = Nic.new(name: 'eth9', mac: 'bb:aa:aa:aa:aa:aa')
          nic2.ip_address = IpAddress.new(addr: '10.1.1.1', netmask: '0.0.0.0', family: 'a')

          nic3 = Nic.new(name: 'eth2', mac: 'cc:aa:aa:aa:aa:aa')
          nic3.ip_address = IpAddress.new

          machine.nics << nic
          machine.nics << nic2
          machine.nics << nic3

          described_class.update_from_facts(machine, @url)
        end

        it 'removes non-existant nics' do
          nic = machine.nics.where(name: 'eth9').first

          expect(nic).to be_nil
          expect(Nic.exists?(name: 'eth9')).to eq(false)
        end

        it 'removes interfaces without ip address' do
          nic = machine.nics.where(name: 'eth2').first

          expect(nic).to be_nil
        end

        describe 'eth0 interface' do
          let(:nic) { machine.nics.find {|n| n.name == 'eth0' } }

          it 'sets the mac address' do
            expect(nic.mac).to eq('aa:aa:aa:aa:aa:aa')
          end

          it 'sets the ip address' do
            expect(nic.ip_address.addr).to eq('1.1.1.1')
          end

          it 'sets the netmask' do
            expect(nic.ip_address.netmask).to eq('0.0.0.0')
          end

          it 'sets the family' do
            expect(nic.ip_address.family).to eq('a')
          end
        end
      end
    end

    describe "monitoring_vm_children" do
      it "updates the children" do
        vm0 = FactoryBot.create(:virtual_machine, fqdn: 'vm0.example.com', owner: machine.owner)
        vm1 = FactoryBot.create(:virtual_machine, fqdn: 'vm1.example.com', owner: machine.owner)
        vmhost = FactoryBot.create(:machine, fqdn: 'vmhost.example.com', owner: machine.owner)
        facts[:monitoring_vm_children] = {vm0.fqdn => vmhost.fqdn, vm1.fqdn => vmhost.fqdn }
        allow(Puppetdb::Facts).to receive(:for_node).and_return(facts)
        described_class.update_from_facts(vmhost, @url)
        # reload the changed objects
        vm0.reload
        vm1.reload
        expect(vm0.vmhost).to eq(vmhost.fqdn)
        expect(vm1.vmhost).to eq(vmhost.fqdn)
      end
    end
  end

  describe '.parse_installed_packages' do
    let(:machine) do
      Machine.create!(fqdn: 'test.example.com')
    end

    context 'without packages' do
      it "returns nil with empty String provided" do
        packages = ""
        expect(described_class.parse_installed_packages(packages)).to be_nil
      end

      it "returns nil with nil provided" do
        packages = nil
        expect(described_class.parse_installed_packages(packages)).to be_nil
      end
    end

    context 'with deb packages provided' do
      it "processes .deb version Strings correctly" do
        packages = "[adaptec-firmware=1.35-2.15.4.noarch gnome-icon-theme=2.28.0-1.2.11.noarch]"
        expect(described_class.parse_installed_packages(packages).first).to eq({:name => "adaptec-firmware", :version => "1.35-2.15.4.noarch"})
        expect(described_class.parse_installed_packages(packages).size).to eq(2)
      end
    end

    context 'with rpm packages provided' do
      it "processes rpm version Strings correctly" do
        packages = "[adaptec-firmware-1.35-2.15.4.noarch gnome-icon-theme-2.28.0-1.2.11.noarch]"
        expect(described_class.parse_installed_packages(packages).first).to eq({:name => "adaptec-firmware", :version => "1.35-2.15.4.noarch"})
        expect(described_class.parse_installed_packages(packages).size).to eq(2)
      end
    end
  end
end
