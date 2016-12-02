require 'spec_helper'

describe SwitchPort do
  let(:attributes) do
    {
      number: '1',
      identifier: '232341',
      nic_id: Nic.new,
      switch_id: Machine.new
    }
  end

  let(:port) { described_class.new(attributes) }

  describe 'validations' do
    it 'is invalid without a number' do
      attributes.delete(:number)

      expect(port).to be_invalid
    end

    it 'is invalid without a nic' do
      attributes.delete(:nic_id)

      expect(port).to be_invalid
    end

    it 'is invalid without a switch' do
      attributes.delete(:switch_id)

      expect(port).to be_invalid
    end
  end
end
