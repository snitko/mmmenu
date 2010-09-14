class MmmenuGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def create_helper
    copy_file "mmmenu_helper.rb", "app/helpers/mmmenu_helper.rb"
  end


end
