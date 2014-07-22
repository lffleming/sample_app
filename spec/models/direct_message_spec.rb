require 'spec_helper'

describe DirectMessage do
  before { @message = DirectMessage.new(content: "Direct Message!", sender_id: 1, recipient_id: 2) }

  subject { @message }

  it { should respond_to(:content) }
  it { should respond_to(:sender) }
  it { should respond_to(:sender_id) }
  it { should respond_to(:recipient) }
  it { should respond_to(:recipient_id) }

  it { should be_valid }

  describe "when content is not present" do
    before { @message.content = " " }
    it { should_not be_valid }
  end

  describe "when sender is not present" do
    before { @message.sender_id = nil }
    it { should_not be_valid }
  end

  describe "when recipient is not present" do
    before { @message.recipient_id = nil }
    it { should_not be_valid }
  end
end
