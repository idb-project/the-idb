require 'spec_helper'

describe ApiToken do
  let(:attributes) do
    {
      token: 'my-token',
      name: 'name of token',
      read: true,
      write: false,
      post_reports: false,
      post_logs: true
    }
  end

  let(:api_token) { described_class.new(attributes) }

  describe 'validations' do
    it 'requires a token' do
      attributes.delete(:token)

      expect(api_token).to be_invalid
    end

    it 'requires a name' do
      attributes.delete(:name)

      expect(api_token).to be_invalid
    end

    it 'requires a unique token' do
      FactoryBot.create :api_token, token: "my_token"
      token = ApiToken.new(token: "my_token", name: "any name")
      expect(token).to be_invalid
      expect(token.errors[:token]).to include("has already been taken")
    end

    it 'is valid with name and token' do
      expect(api_token).to be_valid
    end
  end
end
