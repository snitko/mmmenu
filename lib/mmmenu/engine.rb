class Mmmenu::Engine < Rails::Engine

  paths["app/helpers"] << File.expand_path("../../generators/templates/helpers", __FILE__)
  paths["app/views"]   << File.expand_path("../../generators/templates/views", __FILE__)

end if defined?(Rails::Engine)

ActionController::Base.class_eval do

private

  def mmmenu(&block)
    @menu = Mmmenu.new(:request => request, &block)
  end

end if defined?(ActionController::Base)
