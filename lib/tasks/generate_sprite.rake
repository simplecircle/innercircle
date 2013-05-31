namespace :assets do
  desc "Generate sprite"
  task :generate_sprite do
    require 'sprite_factory'
    SpriteFactory.cssurl = "image-url('$IMAGE')"
    SpriteFactory.run!(Rails.root.join('app', 'assets', 'images', 'icons'), selector:"div.", output_style:"#{Rails.root.join('app', 'assets', 'stylesheets', 'icons')}.css.less")
  end
end

