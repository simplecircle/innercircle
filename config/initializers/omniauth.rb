require 'omniauth'
include OmniAuth

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, "kcrafqgom9ui", "FXyXAJMctckNCkUw",  :scope => 'r_fullprofile', :fields => ["id", "first-name", "last-name", "headline", "industry", "picture-url", "public-profile-url", "location", "skills", "date-of-birth", "phone-numbers", "educations", "three-current-positions" ]
    # The full_host must be explicitly set as Omniauth doesnt parse the subdomain when
    # building out the callback string.
    # OmniAuth.config.full_host = "http://jobcrush.co"
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}