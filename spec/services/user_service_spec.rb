require 'spec_helper'

describe UserService do
  describe '.update_from_virtual_user' do
    let(:vuser) do
      double('VUser', login: 'john', name: 'John', email: 'e',
        attributes: {login: 'john', name: 'John', email: 'e'})
    end

    let(:new_user) { double('NewUser').as_null_object }

    before do
      allow(User).to receive(:find_or_initialize_by).and_yield(new_user).and_return(new_user)
    end

    it 'tries to find an existing user' do
      expect(User).to receive(:find_or_initialize_by).with(login: vuser.login)

      described_class.update_from_virtual_user(vuser)
    end

    context 'with a new user' do
      before do
        allow(new_user).to receive(:new_record?).and_return(true)
        allow(User).to receive(:find_or_initialize_by).and_yield(new_user).and_return(new_user)
      end

      it 'sets the name' do
        expect(new_user).to receive(:name=).with('John')

        described_class.update_from_virtual_user(vuser)
      end

      it 'sets the email' do
        expect(new_user).to receive(:email=).with('e')

        described_class.update_from_virtual_user(vuser)
      end

      it 'saves the record' do
        expect(new_user).to receive(:save!)

        described_class.update_from_virtual_user(vuser)
      end

      it 'sets the password' do
        expect(new_user).to receive(:password=).with('foo')

        described_class.update_from_virtual_user(vuser, 'foo')
      end

      it 'does not change the admin flag if not specified' do
        expect(new_user).not_to receive(:admin=).with(false)

        described_class.update_from_virtual_user(vuser, 'foo')
      end

      it 'sets the admin flag to true' do
        expect(new_user).to receive(:admin=).with(true)

        described_class.update_from_virtual_user(vuser, 'foo', true)
      end

      it 'sets the admin flag to false' do
        expect(new_user).to receive(:admin=).with(false)

        described_class.update_from_virtual_user(vuser, 'foo', false)
      end
    end

    context 'with an existing user' do
      before do
        allow(new_user).to receive(:new_record?).and_return(false)
        allow(User).to receive(:find_or_initialize_by).and_return(new_user)
      end

      it 'does not set the name' do
        expect(new_user).not_to receive(:name=)

        described_class.update_from_virtual_user(vuser)
      end

      it 'does not set the email' do
        expect(new_user).not_to receive(:email=)

        described_class.update_from_virtual_user(vuser)
      end

      it 'updates the user record with the vuser user attributes' do
        expect(new_user).to receive(:update!).with(vuser.attributes)

        described_class.update_from_virtual_user(vuser)
      end

      it 'sets the password' do
        expect(new_user).to receive(:password=).with('foo')

        described_class.update_from_virtual_user(vuser, 'foo')
      end
    end
  end
end
