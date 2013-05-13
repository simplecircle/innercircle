class InstagramUsernameWorker
  include Sidekiq::Worker

  def perform(company_id)
    logger.info "++++++++++++++++++++++++"
    logger.info Company.find(company_id).name
    # Post.new()
  end
end