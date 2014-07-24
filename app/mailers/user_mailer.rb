class UserMailer < ActionMailer::Base
  default from: "ro-reply@sampleapp.com"

  def password_reset(user)
    @user = user

    mail to: user.email, :subject => "Password Reset"
  end

  def follow_notification(user, follower)
    @user = user
    @follower = follower
    mail(:to => "#{user.name} <#{user.email}>", :subject => "You have a new follower!")
  end

  def signup_confirmation(options)
    @confirmation_uri =
      "http://#{options[:host]}#{ confirm_user_path(options[:token]) }"
    mail(:to => options[:email])
  end
end
