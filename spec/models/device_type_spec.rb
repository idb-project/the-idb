require 'spec_helper'

describe DeviceType do
  let(:types) do
    [
      {id: 1, name: 'physical', is_virtual: false},
      {id: 2, name: 'virtual', is_virtual: true},
      {id: 3, name: 'switch'}
    ]
  end

  before do
    allow(IDB.config).to receive(:device_types).and_return(types)
  end

  subject { described_class.new(types[1]) }

  its(:id) { should eq(2) }
  its(:name) { should eq('virtual') }
  its(:is_virtual) { should eq(true) }

  it 'gets the device types from the config object' do
    expect(IDB.config).to receive(:device_types)

    described_class.find(1)
  end

  describe '#find' do
    context 'with an existing device type' do
      it 'returns a device type object' do
        expect(described_class.find(1).name).to eq('physical')
      end
    end

    context 'without a device type for the id' do
      it 'returns nil' do
        expect(described_class.find(112)).to be_nil
      end
    end
  end

  describe '.where' do
    it 'returns a list of objects for the given attribute' do
      expect(described_class.where(name: 'virtual').first.name).to eq('virtual')
    end

    context 'when value is nil' do
      it 'returns an empty list' do
        expect(described_class.where(is_virtual: nil)).to eq([])
      end
    end
  end
end
