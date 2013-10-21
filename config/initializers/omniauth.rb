require 'omniauth'
include OmniAuth

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, "t9b7s5oicfun", "yo2qaKuqWi4iKcc0",  :scope => 'r_network'
  # The full_host must be explicitly set as Omniauth doesnt parse the subdomain when
  # building out the callback string.
  # OmniAuth.config.full_host = "http://jobcrush.co"
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}