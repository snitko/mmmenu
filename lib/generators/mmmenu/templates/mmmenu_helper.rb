module MmmenuHelper

  def build_mmmenu(menu)
    menu.item_markup(0, :active_markup => 'class="current"') do
      |link, text, options| "<li><a href=\"#{link}\" #{options}>#{text}</a></li>\n"
    end
    menu.level_markup(0) { |menu| '<ul class="menu">' + menu + '</ul>' }
    menu.level_markup(1) { |menu| '<ul class="submenu">' + menu + '</ul>' }
    menu.build.html_safe
  end

end
