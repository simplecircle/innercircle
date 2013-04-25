namespace :assets do
  desc "Uploads all /public assets to Rackspace CloudFiles"
  task :sync do
    CloudfilesAssetSync.run
  end
end

