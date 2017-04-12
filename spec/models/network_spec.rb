require 'spec_helper'

describe Network do
  before :each do
    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)
  end

  let(:attributes) do
    {
      name: 'data center',
      address: '10.0.0.1/26',
      description: 'nice network!',
      owner: @owner
    }
  end

  let(:network) { described_class.new(attributes) }

  describe '#ip' do
    it 'returns an IPAddress object' do
      expect(network.ip).to be_a(IPAddress)
    end
  end

  describe 'validations' do
    it 'is not valid without a name' do
      attributes.delete(:name)

      expect(network).to be_invalid
    end

    it 'is not valid without an address' do
      attributes.delete(:address)

      expect(network).to be_invalid
    end

    it 'is not valid with an invalid ip address' do
      attributes[:address] = '10'

      expect(network).to be_invalid
    end
  end

  it 'can have an owner' do
    network.owner = @owner
    network.save!

    expect(network.reload.owner).to eq(@owner)
  end

  describe '#preferences' do
    it 'defaults to an empty hash' do
      expect(network.preferences).to eq({})
    end
  end

  describe '#allowed_ip_addresses' do
    let(:ip) { network.ip.hosts.first.to_s }

    it 'returns an empty list by default' do
      expect(network.allowed_ip_addresses).to eq([])
    end

    it 'can be set' do
      network.allowed_ip_addresses = [ip]

      expect(network.allowed_ip_addresses).to eq([ip])
    end

    it 'persists the list' do
      network.allowed_ip_addresses = [ip]
      network.save

      expect(described_class.find(network.id).allowed_ip_addresses).to eq([ip])
    end

    it 'removes empty and nil entries' do
      network.allowed_ip_addresses = ['', ip, nil]

      expect(network.allowed_ip_addresses).to eq([ip])
    end

    context 'when setting to a single address' do
      it 'stores it as list' do
        network.allowed_ip_addresses = ip
        network.save

        expect(described_class.find(network.id).allowed_ip_addresses).to eq([ip])
      end
    end

    context 'when passing an IPAddress object' do
      it 'converts it to a string' do
        network.allowed_ip_addresses = network.ip.hosts.first

        expect(network.allowed_ip_addresses).to eq([network.ip.hosts.first.to_s])
      end
    end
  end
end
