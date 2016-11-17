require 'spec_helper'

describe IDBQueue::MaintenanceMessage do
  let(:json) do
    fixtures_path('idb_queue/maintenance-record-us-ascii-8bit.json')
  end

  let(:data) { JSON.parse(File.read(json)) }
  let(:message) { described_class.new(data) }

  it 'has a fqdn' do
    expect(message.fqdn).to eq('machine.example.com')
  end

  it 'has a timestamp' do
    expect(message.timestamp).to eq(Time.parse('2013-12-13 09:46:25 +0100'))
  end

  it 'has a screenlog' do
    expect(message.screenlog).to match(/Just a test/)
  end

  describe '#screenlog' do
    it 'is utf-8 encoded' do
      expect(message.screenlog.encoding).to eq(Encoding::UTF_8)
    end

    context 'without a log' do
      before { data['screenlog'] = nil }

      it 'returns nil' do
        expect(message.screenlog).to be_nil
      end
    end

    context 'with an empty log' do
      before { data['screenlog'] = '' }

      it 'returns an empty string' do
        expect(message.screenlog).to be_empty
      end
    end
  end

  describe '#user' do
    let(:user) { message.user }

    it 'has a login' do
      expect(user.login).to eq('tester')
    end

    it 'has a name' do
      expect(user.name).to eq('Tim Tester')
    end

    it 'has an email' do
      expect(user.email).to eq('tester@example.com')
    end
  end
end
