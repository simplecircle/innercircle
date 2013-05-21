class UserMailer < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  add_template_helper(ApplicationHelper)

  default from: "hello@getinnercircle.com"
  Rails.env == "production" ? default_url_options[:host] = "getinnercircle.com" : default_url_options[:host] = "lvh.me"


  def password_reset(user)
    @user = user
    mail(to:user.email, subject:"Password reset")
  end

  def admin_invite(user, company)
    @user = user
    @company = company
    mail(to:user.email, subject:"Invitation from #{@company.name}")
  end
end
