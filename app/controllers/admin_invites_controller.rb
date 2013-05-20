class AdminInvitesController < ApplicationController

  def new
  end

  def create
    email = params[:email]
    if email.blank? or email.match(/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i).nil?
      redirect_to(new_admin_invite_path, alert:"<h3>Please enter a valid email</h3>")
    else
      company = current_user.owned_companies.find {|co| co.subdomain == request.subdomain}
      if company #we found a company the current user has permissions to

        @user = User.find_by_email(email)

        if @user.blank? #Need to create a new user
          @user = company.users.build(:email => email, :role => "admin", :pending => true)
          @user.build_profile
          @user.password = SecureRandom.urlsafe_base64
          if @user.save
            company.users << @user
          else
            redirect_to(new_admin_invite_path, alert:"<h3>Sorry, something went wrong</h3>")
          end
        else
          redirect_to(new_admin_invite_path, alert:"<h3>Sorry, there is already an account registered with that email address</h3>")
        end

        @user.send_admin_invite(company)
        redirect_to(dashboard_url, notice:"<h3>#{email} has been invited as an admin</h3>")

      else #we couldn't find a privilege for the company
        redirect_to(new_admin_invite_path, alert:"<h3>Sorry, you do not have privileges to invite admins</h3>")
      end
    end
  end

  def edit
    @user = User.find_by_admin_invite_token(params[:id])
  end

  def update
    @user = User.find_by_admin_invite_token(params[:id])

    @profile = @user.profile
    if @user.admin_invite_sent_at < 7.days.ago
      redirect_to(new_admin_invite_path, alert:"<h3>Sorry, your invitation has expired. Please request a new one from your company's admin.</h3>")
    elsif @user.update_attributes(params[:user])
      @user.update_attributes(:pending=>false)
      @user.clear_admin_invite_token
      cookies.permanent[:auth_token] = {value:@user.auth_token, domain: :all}
      redirect_to(dashboard_url, notice:"<h3>Welcome!</h3>")
    else
      render :edit
    end
  end

end
