class MicropostsController < ApplicationController
  before_action :signed_in_user
  before_action :correct_user,   only: :destroy
  before_filter :process_direct_message, :only => :create

  def create
    # @micropost = current_user.microposts.build(micropost_params)
    @micropost.in_reply_to = @micropost.reply_to
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :in_reply_to)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end

    def process_direct_message
      @micropost = current_user.microposts.build(micropost_params)
      if @micropost.direct_message?
        direct_message = DirectMessage.new(@micropost.direct_message_hash)
        redirect_to root_path if direct_message.save
      end
    end

end
