require 'spec_helper'

describe Attachment do
  before (:each) do
    @owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    allow(User).to receive(:current).and_return(@owner.users.first)
    @attachment = FactoryGirl.create :attachment
  end

  it "calls the 'check_sha256_fingerprint' method after saving" do
    expect(@attachment).to receive(:check_sha256_fingerprint)
    @attachment.save!
  end

  it "returns only no attachments if none is assigned to the current user" do
    expect(Attachment.all).not_to include @attachment
  end

  it "returns one attachment that is assigned to the current users owner" do
    attachment2 = FactoryGirl.create(:attachment, owner: @owner)
    expect(Attachment.all).not_to include @attachment
    expect(Attachment.all).to include attachment2
  end

  it "returns no attachment that is assigned to another owner" do
    different_owner = FactoryGirl.create(:owner, users: [FactoryGirl.create(:user)])
    attachment3 = FactoryGirl.create(:attachment, owner: different_owner)
    expect(Attachment.all).not_to include @attachment
    expect(Attachment.all).not_to include attachment3
  end
end
