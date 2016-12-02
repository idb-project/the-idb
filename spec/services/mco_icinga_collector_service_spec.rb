require 'spec_helper'

describe McoIcingaCollectorService do
  let(:mco) { double('MCO') }
  let(:mco_responses) { [mco_response] }

  let(:mco_response) do
    McoSocketClient::Response.new({
      'data' => {
        'idb' => {
          "cust.switch" => {
            'host_name' => "cust.switch",
            'alias' => "switch.example.com",
            'address' => "10.0.0.1",
            'services' => [
              "PORT08-host1.example.com-00:00:24:A6:F7:1C",
              "PORT11-host2.example.com-00:00:24:B6:E7:3C"
            ]
          },
          "cust.host" => {
            'host_name' => "cust.host",
            'alias' => "host34.example.com",
            'address' => "10.0.0.2",
            'services' => [
              "DISK",
              "SLAPD"
            ]
          }
        }
      }
    })
  end

  before do
    allow(McoSocketClient).to receive(:new).and_return(mco)
  end

  let(:service) { described_class.new }

  describe '#update_machines' do
    before do
      allow(mco).to receive(:rpc).with('icinga', 'idb').and_return(mco_responses)
    end

    it 'only creates switch machines' do
      service.update_machines

      expect(Machine.count).to eq(1)
    end

    context 'with an alias of nil' do
      it 'skips the node' do
        mco_response['data']['idb']['cust.switch']['alias'] = nil

        service.update_machines
      end
    end

    context 'without a matching switch' do
      it 'creates the switch' do
        service.update_machines

        expect(Machine.first.fqdn).to eq('switch.example.com')
        expect(Machine.first.device_type.name).to eq('switch')
        expect(Machine.first.nics.first.name).to eq('nic')
        expect(Machine.first.nics.first.ip_address.addr).to eq('10.0.0.1')
        expect(Machine.first.nics.first.ip_address.family).to eq('inet')
      end
    end

    context 'with a matching switch' do
      before do
        Machine.create_switch!(fqdn: 'switch.example.com').tap do |switch|
          nic = switch.nics.build(name: 'nic')
          ip = nic.build_ip_address(family: 'inet', addr: '10.0.0.100')

          nic.save!
        end
      end

      it 'updates the switch' do
        service.update_machines

        expect(Machine.first.nics.first.ip_address.addr).to eq('10.0.0.1')
      end
    end

    context 'with a nic for the switch port' do
      before do
        Machine.create!(fqdn: 'host2.example.com').tap do |machine|
          machine.nics.create!(name: 'eth0', mac: '00:00:24:B6:E7:3C'.downcase)
        end

        service.update_machines
      end

      let(:port) { SwitchPort.first }
      let(:switch) { Machine.where(fqdn: 'switch.example.com').first }

      it 'creates a switch port' do
        expect(port.number).to eq(11)
      end

      it 'only creates on switch port' do
        expect(SwitchPort.count).to eq(1)
      end

      it 'creates a switch port with a reference to the switch' do
        expect(port.switch).to eq(switch)
      end

      it 'does not create a second port when called more than once' do
        service.update_machines
        service.update_machines

        expect(SwitchPort.count).to eq(1)
      end
    end

    context 'without nic for the switch port' do
      it 'does not create the switch port' do
        expect(SwitchPort.count).to eq(0)
      end
    end

    context 'with existing switch ports that do not exist in icinga' do
      before do
        Machine.create!(fqdn: 'host2.example.com').tap do |machine|
          machine.nics.create!(name: 'eth0', mac: '00:00:24:B6:E7:3C'.downcase)
        end

        # Ensure we have switch ports.
        service.update_machines
      end

      it 'removes the local switch ports' do
        # No ports on the switch.
        mco_responses[0]['data']['idb']['cust.switch']['services'] = []

        # Return modified mco response.
        allow(mco).to receive(:rpc).with('icinga', 'idb').and_return(mco_responses)

        # Run again to check if ports will be removed.
        service.update_machines

        expect(SwitchPort.count).to eq(0)
      end
    end
  end
end
