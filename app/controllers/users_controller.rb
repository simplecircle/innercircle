class UsersController < ApplicationController

  layout :choose_layout
  # auth handled through get_user
  before_filter :authorize_user, only:[:show]
  # before_filter :get_user, only:[:edit, :update]

  def new
    @user = User.new
    @depts = CompanyDept.all
    @company_connections = true if params[:company_connections]
  end

  def create
    @user = User.new(params_user)
    @user.role = 'talent'
    if @user.save
      # (featured companies) buzzfeed, meetup, warby parker, general assembly, squarespace, songza, huge inc, newscred, kickstarter, razorfush ny
      [73, 72, 64, 49, 48, 43, 40, 39, 18, 47].uniq.each do |co_id|
        Relationship.create!(follower_id:@user.id, followed_id:co_id)
      end
      cookies.permanent[:auth_token] = {value:@user.auth_token, domain: :all}
      redirect_to(new_linkedin_url)
    else
      # UserMailer.welcome(@user, capitalize_phrase(@company.name)).deliver
      render "new"
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    # if params[:autofill] == 'linkedin' #The link for the 'autofill with linkedin' button looks like users/token/edit?autofill=linkedin, so this catches that url and redirects to the linkedin auth page
    #   session[:callback_token] = @user.auth_token
    #   redirect_to "/auth/linkedin"
    # else
    #   @profile = @user.profile
    #   @depts = @profile.company_depts.map(&:id)
    #   @other_job_category = @profile.profiles_company_depts.empty? ? nil : @profile.profiles_company_depts.first.other_job_category
    #   @incoming_tags = @user.profile.skills.map(&:name).join(',')

    #   @alert = 'Sorry, LinkedIn authorization failed' if params[:strategy] == 'linkedin' && params[:message] == 'invalid_credentials'
      
    #   auth = request.env["omniauth.auth"]
    #   if auth
    #     info = auth["info"]

    #     @profile.update_attributes!(
    #       :linkedin_data => JSON.parse(auth.to_json), 
    #       :linkedin_profile => info["urls"]["public_profile"]
    #     )

    #     @profile.first_name = info["first_name"]
    #     @profile.last_name = info["last_name"]
    #     @profile.job_title = info["headline"]
    #     @profile.url = info["urls"]["public_profile"]
    #     @incoming_tags = @incoming_tags + ',' + auth["extra"]["raw_info"]["skills"].values[1].map{|s| s.skill.name}.join(",") unless auth["extra"]["raw_info"]["skills"].nil?

    #     session[:callback_token] = nil
    #     if @is_new_user
    #       @profile.save
    #     end
    #   end
    # end
  end

  def update
    if params[:commit] == "Remove User"
      user_to_delete = User.find(params[:id])
      UsersCompany.where(:company_id => @company.id, :user_id => user_to_delete.id).destroy_all
      return redirect_to dashboard_url, notice: "#{user_to_delete.email} removed from your talent community"
    end
    if params[:commit] == "Save Rating"
      user = User.find(params[:id])
      star_rating = params[:user][:star_rating].to_i
      save_star_rating(star_rating, user.id, @company.id)
      return render :nothing => true
    end
    @user.assign_attributes(params[:user])

    def validate_depts?
      #only validate depts if an existing user, otherwise it will try to validate page 2 of the signup wizard, which doesn't have any depts on it
      !@is_new_user && @user.talent?
    end

    #Save skill list
    if !params[:as_values_true].blank?
      @incoming_tags = params[:as_values_true].split(",").reject(&:empty?).join(",")
      @user.profile.skill_list = @incoming_tags #Need to define it this way so that tags populate on form reload (i.e. if validation fails)
    end

    if validate_depts?
      @depts = params[:company_depts]
      @depts = @depts.map{|x| x.to_i } if !@depts.blank?
      @other_job_category = params[:other_job_category].first
    end

    if validate_depts? && @depts.nil?
      @user.errors.add(:categories, "You have to choose at least one category.")
      throw_err = true
    end

    #Check if user selected "other" but didn't specify
    if validate_depts? && !@depts.nil? && CompanyDept.find(@depts.first.to_i).name == "other" && @other_job_category.blank?
      @user.errors.add(:other_job_category, "Please tell us which category fits you best") if 
      throw_err == true
    end

    if throw_err  
      render "edit"
    else
      if @user.save
        save_departments(@depts, @user.profile, @other_job_category) if validate_depts?
        
        # Add / update mailchimp lists
        if @user.talent? && Rails.env == "production"
          mc = Mailchimp.new
          mc.list_subscribe(@user)
        end

        if @is_new_user
          log_in_new_user @user
          @company.users << @user
          redirect_to confirmation_url(is_kiosk: params[:is_kiosk])
        elsif current_user.god_or_admin?
          redirect_to dashboard_url, notice: "Account Updated"
        else
          redirect_to current_user, notice: "Account Updated"
        end
      else
        render 'edit'
      end
    end
  end

  def linkedin
  end


  private

  def choose_layout
    if ['new', 'create', 'linkedin'].include?(action_name)
      'onboarding'
    else
      'application'
    end
  end

  def params_user
    params.require(:user).permit(:email, :password, :role, :linkedin_connections, :linkedin_access_token, company_dept_ids:[])
  end
end
