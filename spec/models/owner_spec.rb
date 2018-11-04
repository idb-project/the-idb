require 'spec_helper'

describe Owner do
  let(:attributes) do
    {
      name: 'Example Inc.',
      nickname: 'example',
      customer_id: '22022',
      description: 'Nice customer!'
    }
  end

  let(:owner) { described_class.new(attributes) }

  describe 'validations' do
    it 'requires a nickname' do
      attributes.delete(:nickname)

      expect(owner).to be_invalid
    end

    it 'requires a name' do
      attributes.delete(:name)

      expect(owner).to be_invalid
    end

    it 'allows an empty customer_id' do
      attributes.delete(:customer_id)

      expect(owner).to be_valid
    end

    it 'does not allow a duplicate name' do
      owner.save!

      attributes[:nickname] = 'foo'
      attributes[:customer_id] = '123'

      expect(described_class.new(attributes)).to be_invalid
    end

    it 'does not allow a duplicate nickname' do
      owner.save!

      attributes[:name] = 'foo inc.'
      attributes[:customer_id] = '123'

      expect(described_class.new(attributes)).to be_invalid
    end

    it 'does not allow a duplicate nickname' do
      owner.save!

      attributes[:name] = 'foo inc.'
      attributes[:customer_id] = '123'

      expect(described_class.new(attributes)).to be_invalid
    end

    it 'allows a duplicate customer_id' do
      owner.save!

      attributes[:name] = 'foo inc. 2'
      attributes[:nickname] = 'foo2'

      expect(described_class.new(attributes)).to be_valid
    end

    it 'allows an owner with duplicate customer_id to be saved' do
      owner.save!

      attributes[:name] = 'foo inc. 2'
      attributes[:nickname] = 'foo2'

      expect { described_class.create!(attributes) }.to_not raise_error
    end
  end

  describe '#display_name' do
    it 'returns the nickname' do
      expect(owner.display_name).to eq('example')
    end

    context 'without nickname' do
      it 'returns the name' do
        attributes.delete(:nickname)

        expect(owner.display_name).to eq('Example Inc.')
      end
    end
  end

  describe '#data' do
    it 'defaults to an empty hash' do
      expect(owner.data).to eq({})
    end
  end

  describe '#default_owner' do
    before :each do
      @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
      allow(User).to receive(:current).and_return(@owner.users.first)
    end

    it 'returns the configured default owner if exists' do
      IDB.config.default_owner = @owner.id
      expect(Owner.default_owner.id).to eq(IDB.config.default_owner)
    end

    it 'returns the first owner if the configured does not exist' do
      IDB.config.default_owner = -3
      expect(Owner.default_owner.id).to eq(Owner.first.id)
    end

    it 'creates a default owner if none exists' do
      @owner.delete
      expect(Owner.all.size).to eq(0)
      expect(Owner.default_owner.name).to eq("default")
    end
  end
end
