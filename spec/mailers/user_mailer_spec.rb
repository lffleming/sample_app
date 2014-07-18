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
end
