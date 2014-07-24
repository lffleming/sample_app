class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].downcase)
    if user.nil? || !user.authenticate(params[:password])
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    else
      if user.state == "inactive"
        flash[:error] = "Your account isn't confirmed. Please check your email."
        render 'new'
      else
        sign_in user
        redirect_back_or user
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
