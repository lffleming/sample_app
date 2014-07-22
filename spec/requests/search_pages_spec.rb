require 'spec_helper'

describe "Search pages" do
  subject { page }

  describe "index" do
    describe "not signed in" do
      before { visit search_index_path }
      it { should have_title('Sign in') }
    end

    describe "signed in" do
      let(:user) { FactoryGirl.create(:user) }
      before do
       sign_in user
       20.times { FactoryGirl.create(:micropost, user: user) }
       click_link "Search"
      end

      it { should have_title('Search Microposts') }

      describe "with no search text" do
        it "should list all micropost" do
          Micropost.paginate(page: 1).each do |micropost|
            expect(page).to have_selector('li', text: micropost.content)
          end
        end
      end

      describe "with search text" do
        before do
          @not_in_search = FactoryGirl.create(:micropost, content: "Not in search", user: user)
          fill_in "search", with: "Lorem ipsum"
          click_button "Search"
        end

        it "should list all microposts that match" do
          Micropost.search("Lorem ipsum").each do |m|
            expect(page).to have_selector('li', text: m.content)
          end
        end

        it "should not list microposts that doesn't match" do
          expect(page).not_to have_selector('li', text: @not_in_search.content)
        end
      end

    end
  end
end
