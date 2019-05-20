require 'spec_helper'

describe User do
  let(:attributes) do
    {
      login: 'john',
      name: 'John Doe',
      email: 'john@example.com'
    }
  end

  let(:user) { described_class.new(attributes) }

  describe '#display_name' do
    context 'if name is empty' do
      before do
        attributes[:name] = ''
      end

      it 'returns the login' do
        expect(user.display_name).to eq('john')
      end
    end

    context 'if name is nil' do
      before do
        attributes.delete(:name)
      end

      it 'returns the login' do
        expect(user.display_name).to eq('john')
      end
    end
  end

  describe '#is_admin?' do
    it 'returns the admin status' do
      expect(user.is_admin?).to be false

      attributes[:admin] = false
      user.update(attributes)
      expect(user.is_admin?).to be false

      attributes[:admin] = true
      user.update(attributes)
      expect(user.is_admin?).to be true
    end
  end

  describe '#update' do
    before do
      user.save!
    end

    context 'with new attributes' do
      before do
        attributes[:email] = 'johnny@example.com'
      end

      it 'updates the user' do
        user.update(attributes)

        expect(user.email).to eq('johnny@example.com')
      end
    end

    context 'with a nil attribute' do
      before do
        attributes[:name] = nil
      end

      it 'keeps the previous one' do
        user.update(attributes)

        expect(user.name).to eq('John Doe')
      end
    end

    context 'with an empty attribute' do
      before do
        attributes[:name] = ''
      end

      it 'keeps the previous one' do
        user.update(attributes)

        expect(user.name).to eq('John Doe')
      end
    end
  end

  describe 'secure password' do
    it 'creates an encrypted password' do
      user.password = 'foo-bar'

      expect(user.authenticate('foo-bar')).to eq(user)
    end
  end

  describe '#valid_password?' do
    before do
      user.password = 'foobar'
    end

    context 'with blank digest' do
      before { user.password_digest = nil }

      it 'returns false' do
        expect(user.valid_password?('foobar')).to eq(false)
      end
    end

    context 'with correct password' do
      it 'returns true' do
        expect(user.valid_password?('foobar')).to eq(true)
      end
    end

    context 'with incorrect password' do
      it 'returns false' do
        expect(user.valid_password?('__foo')).to eq(false)
      end
    end
  end

  describe "#associates" do
    before(:each) do
      @ass1 = FactoryBot.create(:user)
      @ass2 = FactoryBot.create(:user)
      @ass3 = FactoryBot.create(:user)
      @ass_out = FactoryBot.create(:user)
      @owner = FactoryBot.create(:owner)
      @owner2 = FactoryBot.create(:owner)
      @owner_out = FactoryBot.create(:owner)
    end

    context "without other users associated by owners" do
      it "returns empty list" do
        expect(user.associates).to eq([])
      end
    end

    context "with other users associated by one owner" do
      it "returns one associate" do
        @owner.users << @ass1
        user.owners << @owner
        expect(user.associates).to eq([@ass1])
      end

      it "returns all associates" do
        @owner.users << @ass1
        @owner.users << @ass2
        user.owners << @owner
        expect(user.associates).to eq([@ass1, @ass2])
      end
    end

    context "with other users associated by other owners" do
      it "returns one associate" do
        @owner.users << @ass1
        user.owners << @owner
        expect(user.associates).to eq([@ass1])
      end

      it "returns all associates" do
        @owner.users << @ass1
        @owner.users << @ass2
        @owner2.users << @ass3
        user.owners << @owner
        user.owners << @owner2
        expect(user.associates).to eq([@ass1, @ass2, @ass3])
      end

      it "does not return a user not associated" do
        expect(user.associates).not_to include(@ass_out)
      end
    end
  end
end
