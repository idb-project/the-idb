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
    let(:updated_user) { User.first }

    before do
      user.save!
    end

    context 'with new attributes' do
      before do
        attributes[:email] = 'johnny@example.com'
      end

      it 'updates the user' do
        user.update(attributes)

        expect(updated_user.email).to eq('johnny@example.com')
      end
    end

    context 'with a nil attribute' do
      before do
        attributes[:name] = nil
      end

      it 'keeps the previous one' do
        user.update(attributes)

        expect(updated_user.name).to eq('John Doe')
      end
    end

    context 'with an empty attribute' do
      before do
        attributes[:name] = ''
      end

      it 'keeps the previous one' do
        user.update(attributes)

        expect(updated_user.name).to eq('John Doe')
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
end
