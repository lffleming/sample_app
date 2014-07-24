class SearchController < ApplicationController
  before_action :signed_in_user
  def index
    @feed_items = Micropost.search(params[:search]).paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.rss
      format.xml { render :xml => @feed_items }
      format.json { render :json => @feed_items }
    end
  end
end
