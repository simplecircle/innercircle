# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # Directories where uploaded files will be stored.
  def store_dir
    if Rails.env.development?
      "uploads/dev/#{mounted_as}/#{model.id}"
    elsif Rails.env.test?
      "uploads/test/#{mounted_as}/#{model.id}"
    else
      "#{mounted_as}/#{model.id}"
    end
  end

  version :large do
    process :large
    process :quality=>75
  end
  version :medium, :from_version => :large do
    process :medium
    process :quality=>80
  end

  def large
    manipulate! do |img|
      img.auto_orient!
      img.change_geometry!('500') { |cols, rows, img| img.resize!(cols, rows)}
      img
    end
  end

  def medium
    manipulate! do |img|
      img.auto_orient!
      img.change_geometry!('250') { |cols, rows, img| img.resize!(cols, rows)}
    end
  end

   def extension_white_list
     %w(jpg jpeg png gif)
   end

  def remove!
    begin
      super
    rescue Fog::Storage::Rackspace::NotFound
    end
  end

  # Choose what kind of storage to use for this uploader:
  if Rails.env.production?
    CarrierWave.configure do |config|
      config.fog_credentials = {
        :provider           => 'Rackspace',
        :rackspace_username => 'elliottg',
        :rackspace_api_key  => 'fb5ad52cca76511498bb79eda91cefcf',
        :rackspace_servicenet => Rails.env.production?
      }
      config.fog_directory = "production_innercircle_media"
      config.asset_host = "http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com"
      config.storage = :fog
    end
  elsif Rails.env.staging?
    CarrierWave.configure do |config|
      config.fog_credentials = {
        :provider           => 'Rackspace',
        :rackspace_username => 'elliottg',
        :rackspace_api_key  => 'fb5ad52cca76511498bb79eda91cefcf',
        :rackspace_servicenet => Rails.env.staging?
      }
      config.fog_directory = "staging_innercircle_media"
      config.asset_host = "http://db32ab1e937965fd76a9-6283d20fe675d8c76c27a22322e7037e.r14.cf1.rackcdn.com"
      config.storage = :fog
    end
  else
    CarrierWave.configure do |config|
      config.storage = :file
      config.enable_processing = true
    end
  end
end
