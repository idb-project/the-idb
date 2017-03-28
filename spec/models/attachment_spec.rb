require 'spec_helper'

describe Attachment do
  it "calls the 'check_sha256_fingerprint' method after saving" do
    attachment = FactoryGirl.create :attachment
    expect(attachment).to receive(:check_sha256_fingerprint)
    attachment.save!
  end
end
