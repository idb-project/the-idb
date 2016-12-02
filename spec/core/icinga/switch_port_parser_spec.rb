require 'spec_helper'

describe Icinga::SwitchPortParser do
  let(:input) { 'PORT08-leitstand2.example.com-00:00:24:C6:E7:1C' }

  let(:parser) { described_class.new(input) }

  describe '#port' do
    it 'returns the port' do
      expect(parser.port).to eq(8)
    end
  end

  describe '#fqdn' do
    it 'returns the machine fqdn' do
      expect(parser.fqdn).to eq('leitstand2.example.com')
    end
  end

  describe '#mac' do
    it 'returns the machine mac' do
      expect(parser.mac).to eq('00:00:24:c6:e7:1c')
    end
  end

  describe '#to_switch_port' do
    let(:switchport) { parser.to_switch_port }

    context 'with a nic' do
      before do
        Nic.create!(name: 'eth0', mac: '00:00:24:c6:e7:1c')
      end

      it 'returns a switch port object' do
        expect(switchport).to be_a(SwitchPort)
      end

      it 'is a new switch port object' do
        expect(switchport).to be_new_record
      end

      it 'has a nic object' do
        expect(switchport.nic.mac).to eq(parser.mac)
      end

      context 'with an existing switch port' do
        before do
          port = parser.to_switch_port
          port.switch_id = 1
          port.save!
        end

        it 'returns the existing switch port' do
          expect(switchport).to_not be_new_record
        end
      end
    end

    context 'without a nic' do
      it 'returns nil' do
        expect(switchport).to be_nil
      end
    end
  end

  context 'with invalid input' do
    let(:input) { 'PORT08-leitstand2.example.com-00:24:C6:E7:1C' }

    it 'raises an exception' do
      expect { parser }.to raise_error(Icinga::SwitchPortParser::ParserError)
    end
  end
end
