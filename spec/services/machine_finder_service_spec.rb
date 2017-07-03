require 'spec_helper'

describe MachineFinderService do
  describe '.find_untracked_machines' do
    before do
      allow(User).to receive(:current).and_return(nil) # no current user present
      @machine = Machine.create!(fqdn: 'test.example.com')
      IDB.config.puppetdb.auto_create = true
      IDB.config.puppetdb.api_urls = {}
      allow(Puppetdb::Nodes.new).to receive(:all).and_return([])
      allow(Puppetdb::NodesV4.new).to receive(:all).and_return([])
      @mfs = MachineFinderService.new(nil)
    end

    it 'creates a machine that has been found in a PuppetDB but not locally' do
      nodes = ["test2.example.com"]
      @mfs.instance_variable_set(:@nodes, nodes) 

      @mfs.find_untracked_machines
      expect(Machine.last.fqdn).to eq(nodes.last)
    end

    it 'does not create a machine that already exists' do
      nodes = ["test.example.com"]
      @mfs.instance_variable_set(:@nodes, nodes) 

      expect(Machine).not_to receive(:new).with(fqdn: nodes.last)
      @mfs.find_untracked_machines
    end

    it 'does not create a machine that is in softdelete state, but all other new machines' do
      @machine.destroy

      nodes = ["test.example.com", "test3.example.com"]
      @mfs.instance_variable_set(:@nodes, nodes) 

      @mfs.find_untracked_machines
      expect(Machine.find_by_fqdn(nodes.first)).to be_nil
      expect(Machine.find_by_fqdn(nodes.last)).not_to be_nil
    end
  end
end
