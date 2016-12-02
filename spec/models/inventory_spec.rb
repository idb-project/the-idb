require 'spec_helper'

describe Inventory do
  let(:attributes) do
    {
      inventory_number: '201507-001',
      name: 'HP switch',
      serial: '9879879',
      part_number: 'XX234XX',
      purchase_date: '2015-04-01',
      warranty_end: '2017-04-01',
      seller: 'Cheap IT stuff',
      comment: 'Just a comment',
      location_id: 2
    }
  end

  let(:inventory) { described_class.new(attributes) }

  describe 'validations' do
    it 'allows an empty name' do
      attributes.delete(:name)

      expect(inventory).to be_valid
    end

    it 'allows empty purchase_date' do
      inventory.purchase_date = ''

      expect(inventory).to be_valid
    end

    it 'allows empty warranty_end' do
      inventory.warranty_end = ''

      expect(inventory).to be_valid
    end

    it 'expects certain format of purchase_date' do
      inventory.purchase_date = 'abc'

      expect(inventory).to be_invalid
    end

    it 'expects certain format of warranty_end' do
      inventory.warranty_end = '2015-07'

      expect(inventory).to be_invalid
    end
  end

  describe "active?" do
    it 'returns true if status is active' do
      inventory.inventory_status = InventoryStatus.new(name: "in use")

      expect(inventory.active?).to be true
    end

    it 'returns false if status is not active' do
      inventory.inventory_status = InventoryStatus.new(name: "broken", inactive: true)

      expect(inventory.active?).to be false
    end
  end
end
