module MmmenuHelper

  def build_mmmenu(menu, options = {})
    return nil unless menu
    options = {templates_path: 'mmmenu' }.merge(options)
    templates_path = options[:templates_path]
    menu.item_markup(1) do |link, text, options|
      render(:partial => "#{templates_path}/item", :locals => { :link => link, :text => text, :options => options })
    end
    menu.current_item_markup(1) do |link, text, options|
      render(:partial => "#{templates_path}/current_item", :locals => { :link => link, :text => text, :options => options })
    end
    menu.level_markup(1) { |m| render(:partial => "#{templates_path}/level_1", :locals => { :menu => m }) }
    menu.level_markup(2) { |m| render(:partial => "#{templates_path}/level_2", :locals => { :menu => m }) }
    menu.build.html_safe
  end

end
