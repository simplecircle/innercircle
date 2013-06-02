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

  def content_update(user, company)
    @company = company

    @posts_to_review_count = company.posts_to_review_count
    @posts_auto_published_count = company.posts_auto_published_count(1.day.ago)
    @total_new_posts = @posts_to_review_count + @posts_auto_published_count

    mail(to:user.email, subject:"#{@total_new_posts} New Post#{@total_new_posts != 1 ? 's' : ''} on Inner Circle")

  end

end
