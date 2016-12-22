require 'spec_helper'

describe CloudProvider do
  let(:attributes) do
    {
      name: 'digitalocean',
      config: 'my_config',
      apidocs: 'http://myapi.example.com',
      description: 'some text'
    }
  end

  let(:cp) { described_class.new(attributes) }

  describe 'validations' do
    it 'does not allow an empty name' do
      attributes.delete(:name)

      expect(cp).to be_invalid
    end

    it "requires that names are unique" do
      cp = FactoryGirl.create :cloud_provider
      cp2 = FactoryGirl.build :cloud_provider, name: cp.name
      expect(cp2).to be_invalid
    end

    it 'allows empty config' do
      cp.config = ''

      expect(cp).to be_valid
    end

    it 'allows empty apidocs' do
      cp.apidocs = ''

      expect(cp).to be_valid
    end

    it 'allows empty description' do
      cp.description = ''

      expect(cp).to be_valid
    end
  end
end
