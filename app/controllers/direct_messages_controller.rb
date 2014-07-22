class DirectMessagesController < ApplicationController
  before_action :signed_in_user
  def sent
    @direct_messages = DirectMessage.where("sender_id = ?", current_user.id).paginate(:page => params[:page])
  end

  def received
    @direct_messages = DirectMessage.where("recipient_id = ?", current_user.id).paginate(:page => params[:page])
  end
end
