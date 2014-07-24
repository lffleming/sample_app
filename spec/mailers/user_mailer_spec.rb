require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      visit new_password_reset_path
      fill_in "Email", with: user.email
      click_button "Reset Password"
    end
    it "should send an email to user" do
      EMAILS.last.to.should include(user.email)
    end

    it "should have the right content" do
      EMAILS.last.body.encoded.should have_content("To reset your password")
    end
  end

  describe "following email" do
    let(:user) { FactoryGirl.create(:user) }
    let(:followed_user) { FactoryGirl.create(:user) }
    describe "with notification active" do
      before { user.follow!(followed_user) }
      it "should send an email" do
        EMAILS.last.to.should include(followed_user.email)
      end
      it "should have proper body" do
        EMAILS.last.body.encoded.should have_content("#{user.name} is now following you!")
      end
    end
    describe "with notification inactive" do
      let(:other_user) { FactoryGirl.create(:user, notification: false) }
      before { user.follow!(other_user) }
      it "should not send an email" do
        expect(EMAILS).to be_empty
      end
    end
  end

  describe "signup confirmation" do
    before do
      visit signup_path
      create_user
      click_button "Create my account"
    end
    it "should be emailed" do
      EMAILS.last.to.should include("user@example.com")
    end
  end
end
