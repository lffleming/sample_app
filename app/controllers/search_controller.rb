class SearchController < ApplicationController
  before_action :signed_in_user
  def index
    @feed_items = Micropost.search(params[:search]).paginate(page: params[:page])
  end
end
