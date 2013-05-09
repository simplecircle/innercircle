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
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to(new_password_reset_path, notice:"<h2>Password reset has expired</h2>")
    elsif @user.update_attributes(params[:user])
      cookies.permanent[:auth_token] = {value:@user.auth_token, domain: :all}
      redirect_to(root_path, notice:"<h2>You're good to go!</h2>")
    else
      render :edit
    end
  end

end
