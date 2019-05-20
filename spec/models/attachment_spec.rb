require 'spec_helper'

describe Attachment do
  before (:each) do
    @owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)
    @attachment = FactoryBot.create :attachment, owner: FactoryBot.create(:owner)
  end

  it "calls the 'check_sha256_fingerprint' method after saving" do
    expect(@attachment).to receive(:check_sha256_fingerprint)
    @attachment.save!
  end

  it "returns only no attachments if none is assigned to the current user" do
    expect(Attachment.all).not_to include @attachment
  end

  it "returns one attachment that is assigned to the current users owner" do
    attachment2 = FactoryBot.create(:attachment, owner: @owner)
    expect(Attachment.all).to include attachment2
    expect(Attachment.all).not_to include @attachment
  end

  it "returns no attachment that is assigned to another owner" do
    different_owner = FactoryBot.create(:owner, users: [FactoryBot.create(:user)])
    attachment3 = FactoryBot.create(:attachment, owner: different_owner)
    expect(Attachment.all).not_to include @attachment
    expect(Attachment.all).not_to include attachment3
  end
end
