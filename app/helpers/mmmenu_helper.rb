module MmmenuHelper

  def build_mmmenu(menu)
    return nil unless menu
    menu.item_markup(1) do |link, text, options|
      render(:partial => "mmmenu/item", :locals => { :link => link, :text => text, :options => options })
    end
    menu.current_item_markup(1) do |link, text, options|
      render(:partial => "mmmenu/current_item", :locals => { :link => link, :text => text, :options => options })
    end
    menu.level_markup(1) { |m| render(:partial => "mmmenu/level_1", :locals => { :menu => m }) }
    menu.level_markup(2) { |m| render(:partial => "mmmenu/level_2", :locals => { :menu => m }) }
    menu.build.html_safe
  end

end
