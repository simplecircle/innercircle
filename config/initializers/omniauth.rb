require 'omniauth'
include OmniAuth

Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env == "development" or Rails.env == "test"
    provider :linkedin, "kcrafqgom9ui", "FXyXAJMctckNCkUw",  :scope => 'r_fullprofile',
           :fields => ["id", "email-address", "first-name", "last-name",
                       "headline", "industry", "picture-url", "public-profile-url",
                       "location", "skills", "date-of-birth", "phone-numbers",
                       "educations", "three-current-positions" ]
  elsif Rails.env == "staging"
    # The full_host must be explicitly set as Omniauth doesnt parse the subdomain when
    # building out the callback string.
    OmniAuth.config.full_host = "http://devstream.me"
    provider :linkedin, "kcrafqgom9ui", "FXyXAJMctckNCkUw"
  else
    provider :linkedin, "kcrafqgom9ui", "FXyXAJMctckNCkUw"
  end
end

