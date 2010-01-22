Mmmenu
======

*Flexible menu generator for rails*

Why another menu plugin?
------------------------
All menu plugins I've seen have HTML markup hardcoded into them.
*Mmmenu* offers you a chance to define your own markup, along with
a nice DSL to describe multi-level menu structures. Let me show you an example,
imagine you put this into your controller:

    @menu = Mmmenu.new(:request => request) do |l1|

      l1.add "Articles", "/articles" do |l2|
       l2.add "Create article",   new_article_path
       l2.add "Articles authors", "/articles/authors", :match_subpaths => true
      end
      l1.add "Item2", "/path2"
      l1.add "Item3", "/path3"
      l1.add "Item4", "/path4"

    end 

As you can see, we specify the paths, so our menu does not depend on the routes.
Now let's see what happens in the views:

  <%= build_mmmenu(@menu) %>

And that's it, you get your menu rendered. Now, like I promised, the html-markup is totally
configurable: that's because mmmenu_helper.rb file with `#build_mmmenu` helper method was generated,
when you installed the plugin. Let's take a look at what's inside this helper:

    def build_mmmenu(menu)
      menu.item_markup(0, :active_markup => 'class="current"') do
        |link, text, options| "<li><a href=\"#{link}\" #{options}>#{text}</a></li>\n"
      end
      menu.level_markup(0) { |menu| '<ul class="menu">' + menu + '</ul>' }
      menu.level_markup(1) { |menu| '<ul class="submenu">' + menu + '</ul>' }
      menu.build
    end

You can see now, that `#item_markup` method defines the html markup for menu item,
and `#level_markup` does the same for menu level wrapper. They may contain as much levels
as you want and you don't need to define a markup for each level: the deepest level markup
defined will be used for all of the deeper levels. Now go ahead and change this method the way you like.

Finally, let's take a closer look at some of the options and what they mean.
---------------------------------------------------------------------
* Active item
Mmmenu automatically marks each menu_item if it is active with the markup, that you provide with
:active_markup option for `#item_markup` method. The item is considered active not only if the path
match, but also if one of the children of the item is active.

* Paths
For each menu item you may specify a number of paths, that should match for the item to be active.
Unless you provide the `:path` option for `Mmmenu#add`, the second argument is used as the matching path.
If you'd like to specify paths explicitly, do something like this:

    `l1.add "Articles" articles_path, :paths => [[new_article_path, 'get'], [articles_path, 'post'], [articles_path, 'get']]`

This way, the menu item will appear active even when you're on the /articles/new page.
Alernatively, you can do this:

    l1.add "Articles" articles_path, :match_subpaths => true

That's much easier usually.


INSTALLATION
------------

1. git submodule add git://github.com/snitko/mmmenu.git vendor/plugins/mmmenu
2. script/generate mmmenu
