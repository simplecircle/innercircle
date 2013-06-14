class AdminInvitesController < ApplicationController

  before_filter :authorize, except:[:update, :edit]

  def new
  end

  def show
    @user = User.find_by_admin_invite_token(params[:id])
  end

  def destroy
    @user = User.find_by_admin_invite_token(params[:id])
    if current_user.owned_companies.map(&:id).include? @user.companies.first.id #check to see we have the permission to revoke
      @user.destroy
      redirect_to dashboard_url, notice: "Invitation revoked"
    else
      redirect_to dashboard_url
    end
  end

  def create
    email = params[:email]
    if email.blank? or email.match(/^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i).nil?
      redirect_to(new_admin_invite_path, alert:"Please enter a valid email")
    else
      company = current_user.owned_companies.find {|co| co.subdomain == request.subdomain}
      user = User.find_by_email(email)

      if user.nil? #Need to create a new user
        user = company.users.build(:email => email, :role => "admin", :pending => true)
        user.build_profile
        user.password = SecureRandom.urlsafe_base64
        user.save
        company.users << user
        user.send_admin_invite(company)
        redirect_to(dashboard_url, notice:"#{email} has been invited as an admin")
      else
        redirect_to(new_admin_invite_path, alert:"Sorry, there is already an account registered with that email address")
      end
    end
  end

  def edit
    @user = User.find_by_admin_invite_token(params[:id])
  end

  def update
    @user = User.find_by_admin_invite_token(params[:id])
    @user.assign_attributes(params[:user])
    @profile = @user.profile

    if @user.profile.first_name.blank? || @user.profile.last_name.blank?
      @user.valid?
      @user.errors.add(:name, "Please your first and last name")
      render :edit
    elsif @user.admin_invite_sent_at < 7.days.ago
      redirect_to(new_admin_invite_path, alert:"Sorry, your invitation has expired. Please request a new one from your company's admin.")
    elsif @user.save
      @user.update_attributes(:pending=>false)
      @user.clear_admin_invite_token
      cookies.permanent[:auth_token] = {value:@user.auth_token, domain: :all}
      redirect_to(dashboard_url, notice:"Welcome!")
    else
      render :edit
    end
  end

end
