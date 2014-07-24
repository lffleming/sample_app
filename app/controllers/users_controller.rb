require 'crypto'
class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :signup_user, only: [:new, :create]

  def index
    @users = User.search(params[:search]).paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.xml  { render :xml => @users }
      format.rss
    end
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.xml  { render :xml => { user: @user, microposts: @microposts } }
      format.rss
    end
  end

  def new
    @user = User.new
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def create
    @user = User.new(user_params)
    if @user.save

      respond_to do |format|
        format.xml  { render :xml => { user: @user, success: true } }
        format.json  { render :json => { user: @user, success: true } }
        format.html {
          UserMailer.signup_confirmation(:token => Crypto.encrypt("#{@user.id}"), :email => @user.email).deliver
          flash[:notice] = "To complete registration, please check your email."
          redirect_to root_url
        }
      end

    else

      respond_to do |format|
        format.html { render 'new' }
        format.xml  { render :xml => { user: @user, success: false } }
        format.json  { render :json => { user: @user, success: false } }
      end

    end

  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def confirm
    begin
      @user = User.find( Crypto.decrypt(params[:id]) )
      @user.disable_validation = true
      @user.activate!
      sign_in @user
      flash[:success] = "Account confirmed. Welcome #{@user.name}!"
      redirect_to root_url
    rescue StateMachine::InvalidTransition
      sign_out if signed_in?
      flash[:notice] = "Account is already activated. Please sign in instead."
      redirect_to signin_path
    rescue
      flash[:error] = "Invalid confirmation token."
      redirect_to root_url
    ensure
      @user.disable_validation = false if @user
    end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'show_follow' }
      format.xml  { render :xml => @users }
    end
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    respond_to do |format|
      format.html { render 'show_follow' }
      format.xml  { render :xml => @users }
    end

  end

   private

  def user_params
    params.require(:user).permit(:name, :username, :email, :password,
                                 :password_confirmation, :notification)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user.admin? && !current_user?(@user)
  end

  def signup_user
    redirect_to(root_url) if signed_in?
  end

end
