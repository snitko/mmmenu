class MmmenuGenerator < Rails::Generators::Base

  source_root File.expand_path('../templates', __FILE__)

  def create_helper
    copy_file "../../../../app/helpers/mmmenu_helper.rb",       "app/helpers/mmmenu_helper.rb"
    copy_file "../../../../app/views/mmmenu/_item.erb",         "app/views/mmmenu/_item.erb"
    copy_file "../../../../app/views/mmmenu/_current_item.erb", "app/views/mmmenu/_current_item.erb"
    copy_file "../../../../app/views/mmmenu/_level_1.erb",      "app/views/mmmenu/_level_1.erb"
    copy_file "../../../../app/views/mmmenu/_level_2.erb",      "app/views/mmmenu/_level_2.erb"
  end


end
