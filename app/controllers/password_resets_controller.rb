class PasswordResetsController < ApplicationController

  def new
  end

  def create
    if params[:email]
      user = User.find_by_email(params[:email].downcase)
      if user
        user.send_password_reset
         redirect_to(new_password_reset_path, notice:"<h3>Check your email for reset instructions</h3>")
      else
        redirect_to(new_password_reset_path, alert:"<h3>Email not found</h3>")
      end
    end
  end

  def edit
    @user = User.find_by_password_reset_token(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token(params[:id])
    if !@user || @user.password_reset_sent_at < 2.hours.ago
      redirect_to(new_password_reset_path, alert:"<h3>Password reset has expired</h3>")
    elsif @user.update_attributes(:password=>params[:user][:password], :password_confirmation=>params[:user][:password_confirmation])
      cookies.permanent[:auth_token] = {value:@user.auth_token, domain: :all}
      @user.clear_password_reset_token
      redirect_to(user_path(id:@user.id), notice:"<h3>Your password has been reset</h3>")
    else
      render :edit
    end
  end

end
