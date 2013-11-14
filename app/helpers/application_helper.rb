module ApplicationHelper
  include ActionView::Helpers::UrlHelper

  def url_for_cdn_image(model, image_url)
    case model.class.name.downcase
    when "post"
      attachment_name = "photo"
    else
      attachment_name = "logo"
    end
    if Rails.env.development?
      # This condit allows for local and CDN legacy files from a prod DB dump.
      if FileTest.exists?("public/uploads/dev/#{attachment_name}/#{model.id}/#{File.basename(image_url)}")
        "/uploads/dev/#{attachment_name}/#{model.id}/#{File.basename(image_url)}"
      else
        "http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/#{attachment_name}/#{model.id}/#{File.basename(image_url)}"
      end
    elsif Rails.env.test?
      "/uploads/test/#{attachment_name}/#{model.id}/#{File.basename(image_url)}"
    elsif Rails.env.staging?
      "http://c306262.r62.cf1.rackcdn.com/#{attachment_name}/#{model.id}/#{File.basename(image_url)}"
    else
      "http://06f29b33afa7ef966463-b188da212eda95ba370d870e1e01c1c9.r45.cf1.rackcdn.com/#{attachment_name}/#{model.id}/#{File.basename(image_url)}"
    end
  end
  
  def normalize_provider_identifiers(provider_identifiers)
    # must be a string
    provider_identifiers.split(",").map{|pi| pi.downcase.gsub(" ", "")}.uniq.join(",")
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'current' : nil
    link_to(link_text, link_path, class:"#{class_name}")
  end

end
