require 'spec_helper'

describe BasicUserAuth do
  let(:realm) { 'AUTH' }
  let(:context) { double('Context').as_null_object }
  let(:auth) { described_class.new(realm, context)}
  let(:ldap) { double('LDAPConnection').as_null_object }
  let(:ldap_user) { double('LDAPUser') }
  let(:user) { double('User') }

  before do
    allow(UserService).to receive(:update_from_virtual_user)
    allow(LDAP::Connection).to receive(:new).and_return(ldap)

    allow(context).to receive(:authenticate).and_yield('login', 'pass')
  end

  describe '#authenticate' do
    it 'calls the validate method with login and pass' do
      expect(auth).to receive(:validate).with('login', 'pass', nil)

      auth.authenticate('login', 'pass')
    end

    context 'with a valid login' do
      before do
        allow(auth).to receive(:validate).and_yield(user).and_return(true)
      end

      it 'sets current_user on the context' do
        expect(context).to receive(:current_user=).with(user)

        auth.authenticate('login', 'pass')
      end
    end

    context 'with an invalid login' do
      before do
        allow(auth).to receive(:validate).and_return(false)
      end

      it 'does not set current_user on the context' do
        expect(context).not_to receive(:current_user=)

        auth.authenticate('login', 'pass')
      end
    end
  end

  describe '#validate' do
    it 'creates a new ldap connection' do
      expect(LDAP::Connection).to receive(:new).with(IDB.config.ldap)

      auth.validate('login', 'pass')
    end

    context 'if a user is found' do
      before do
        allow(ldap).to receive(:find_user).with('login', 'pass').and_return(ldap_user)
        allow(ldap).to receive(:is_admin?).and_return(false)
        allow(UserService).to receive(:update_from_virtual_user).with(ldap_user, 'pass', false).and_return(user)
      end

      it 'yields the user' do
        value = nil
        auth.validate('login', 'pass') {|u| value = u }

        expect(value).to eq(user)
      end

      it 'returns true' do
        expect(auth.validate('login', 'pass')).to eq(ldap_user)
      end
    end

    context 'if no user can be found' do
      before do
        allow(ldap).to receive(:find_user).with('login', 'pass').and_return(nil)
      end

      it 'does not yield' do
        value = nil
        auth.validate('login', 'pass') {|u| value = true }

        expect(value).to be_nil
      end

      it 'returns nil' do
        expect(auth.validate('login', 'pass')).to be_nil
      end
    end
  end
end
