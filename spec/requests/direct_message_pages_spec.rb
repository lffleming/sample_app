require 'spec_helper'

describe "Direct Message pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:other_user) { FactoryGirl.create(:user) }

  before do
    DirectMessage.create!(content: "Hello my Friend!",
                          sender_id: user.id, recipient_id: other_user.id)
  end

  describe "sent" do
    before do
     sign_in user
     click_link "Sent"
    end

    it { should have_title('Messages Sent') }
    it { should have_content('Messages Sent') }

    it { should have_content("Hello") }

  end

  describe "received" do
    before do
     sign_in other_user
     click_link "Received"
    end

    it { should have_title('Messages Received') }
    it { should have_content('Messages Received') }

    it { should have_content("Hello") }
  end

end
