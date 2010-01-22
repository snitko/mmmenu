class MmmenuGenerator < Rails::Generator::Base

  def manifest

    record do |m|
      m.file "mmmenu_helper.rb", "app/helpers/mmmenu_helper.rb"
    end

  end

end
