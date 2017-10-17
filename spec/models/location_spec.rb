require 'spec_helper'

describe Location do
  before :each do
    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)
  end

  let(:attributes) do
    {
      name: 'Frankfurt',
      description: '',
      location_level_id: 2
    }
  end

  let(:location) { described_class.create(attributes) }

  describe 'validations' do
    it 'requires a name' do
      attributes.delete(:name)

      expect(location).to be_invalid
    end

    it 'does not require a location level id' do
      attributes.delete(:location_level_id)

      expect(location).to be_valid
    end

    it 'allows empty description' do
      location.description = ''

      expect(location).to be_valid
    end
  end

  describe 'has_parent' do
    it 'returns false if no parent exists' do
      expect(location.has_parent?).to be false
    end

    it 'returns true if parent exists' do
      location.parent = FactoryGirl.create :location

      expect(location.has_parent?).to be true
    end
  end

  describe 'location_name' do
    it 'returns the name without parent locations' do
      location = FactoryGirl.create :location, owner: @owner
      expect(location.location_name).to eq(location.name)
    end

    it 'returns full path if one parent' do
      parent = FactoryGirl.create :location, owner: @owner
      parent.add_child(location)

      expect(location.location_name).to eq(parent.name + " → " + location.name)
    end

    it 'returns full path if more parents' do
      parent1 = FactoryGirl.create :location, owner: @owner
      parent2 = FactoryGirl.create(:location, name: 'second parent', owner: @owner)
      parent1.add_child(parent2)
      parent2.add_child(location)

      expect(location.location_name).to eq(parent1.name + " → " + parent2.name + " → " + location.name)
    end
  end
end
