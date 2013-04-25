namespace :assets do
  desc "Uploads all /public assets to Rackspace CloudFiles"
  task :sync do
    module CloudfilesAssetSync
      def asset_files
        Dir[File.join(Rails.root, 'public', 'assets')].reject{|file| File.directory?(file)}
      end
    end
    CloudfilesAssetSync.run
  end
end

