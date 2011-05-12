module MmmenuHelper

  def build_mmmenu(menu)
    menu.item_markup(0, :active_markup => 'class="current"') do |link, text, options|
      render(:partial => "mmmenu/item", :locals => { :link => link, :text => text, :options => options })
    end
    menu.level_markup(0) { |m| render(:partial => "mmmenu/level_1", :locals => { :menu => m }) }
    menu.level_markup(1) { |m| render(:partial => "mmmenu/level_2", :locals => { :menu => m }) }
    menu.build.html_safe
  end

end
