require 'spec_helper'

describe "Micropost pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end

      describe "with reply" do
        before do
         fill_in 'micropost_content', with: "@example Lorem ipsum"
         click_button "Post"
        end
        let(:micropost) { Micropost.all.last}
        it "should fill in in_reply_to field" do
          micropost.in_reply_to.should == "example"
        end
      end

      describe "with direct mesage" do
        before do
         fill_in 'micropost_content', with: "d @recipient direct message"
         @recipient = FactoryGirl.create(:user, :username => 'recipient')
        end

        it "should be saved into the direct_messages table instead" do
          expect { click_button "Post" }.to change(DirectMessage, :count).by(1)
        end

        it "should not be saved into the microposts table" do
          expect { click_button "Post" }.not_to change(Micropost, :count).by(1)
        end
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe "micropost count" do
    before do
      FactoryGirl.create(:micropost, user: user)
      visit root_path
    end

    it "should have the correct micropost count and proper pluralization" do
        expect(page).to have_content("micropost".pluralize(user.feed.count))
    end
  end

  describe "pagination" do

      before do
        40.times { FactoryGirl.create(:micropost, user: user) }
        visit root_path
      end
      after  { User.delete_all }

      it "should have pagination" do
       expect(page).to have_selector('.pagination')
     end

      it "should list each micropost" do
        user.feed.paginate(page: 1).each do |micropost|
          expect(page).to have_selector('.content', text: micropost.content)
        end
      end
    end
end
