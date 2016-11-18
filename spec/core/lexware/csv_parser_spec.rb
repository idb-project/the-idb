# encoding: utf-8

require 'spec_helper'

describe Lexware::CSVParser do

  let(:input) do
    fixtures_path('lexware/import.csv')
  end

  let(:parser) { described_class.new(input) }

  describe '#process' do
    it 'returns a list of customer objects' do
      expect(parser.process.map(&:class)).to eq([Lexware::Customer, Lexware::Customer])
    end

    describe 'first customer' do
      subject { parser.process.first }

      its(:customer_id) { should eq(20101) }
      its(:firstname) { should eq('Vorname') }
      its(:lastname) { should eq('Name') }
      its(:company) { should eq('Atikon EDV & Marketing GmbH') }
      its(:contact_person) { should eq('Stefan Seifert') }
      its(:street) { should eq('Garnisonstraße 21') }
      its(:zipcode) { should eq('4020') }
      its(:city) { should eq('Linz') }
      its(:country) { should eq('Österreich') }
      its(:phone) { should eq('+441234') }
      its(:email) { should eq('stefan.seifert@atikon.com') }
    end
  end
end
