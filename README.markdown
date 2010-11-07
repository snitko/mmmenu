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
        |link, text, options| "<li><a href=\"#{link}\" #{options[:active]}>#{text}</a></li>\n"
      end
      menu.level_markup(0) { |menu| '<ul class="menu">' + menu + '</ul>' }
      menu.level_markup(1) { |menu| '<ul class="submenu">' + menu + '</ul>' }
      menu.build
    end

You can see now, that `#item_markup` method defines the html markup for menu item,
and `#level_markup` does the same for menu level wrapper. They may contain as much levels
as you want and you don't need to define a markup for each level: the deepest level markup
defined will be used for all of the deeper levels.

Moreover, you might want to highlight `li` tag and pass some class to `a` tag, you can
do it like this:

    def build_mmmenu(menu)
      menu.item_markup(0, :active_markup => 'class="current"') do
        |link, text, options| "<li #{options[:active]}><a href=\"#{link}\" class=\"#{options[:html]}\">#{text}</a></li>\n"
      end
      menu.build
    end

    @menu = Mmmenu.new(:request => @request) do |m|
      m.add 'Item1', '/items1', :match_subpaths => true
      m.add 'Item2', '/items2', :html => 'class="special_link"' do |subm|
        subm.add 'New', '/item2/new'
        subm.add 'Edit', '/item2/edit', :html => 'huh'
      end
    end

Or, in combination with powered by Rails `#content_tag` and `#link_to` like this:

    def build_mmmenu(menu)
      menu.item_markup(0, :active_markup => { :class => :current }) do
        |link, text, options| content_tag(:li, link_to(text, link, options[:html]), options[:active])
      end
      menu.build
    end

    @menu = Mmmenu.new(:request => @request) do |m|
      m.add 'Item1', '/items1', :match_subpaths => true
      m.add 'Item2', '/items2', :html => { :class => :special_link } do |subm|
        subm.add 'New', '/item2/new'
        subm.add 'Edit', '/item2/edit'
      end
    end

Now go ahead and change this method the way you like.

Finally, let's take a closer look at some of the options and what they mean.
---------------------------------------------------------------------
* Active item
Mmmenu automatically marks each menu_item if it is active with the markup, that you provide with
:active_markup option for `#item_markup` method. The item is considered active not only if the path
match, but also if one of the children of the item is active. You may as well set the active item manually like that:

  @menu.active_item = '/articles'

In this case `'/articles'` would match against the second argument that you pass to the `#add` method, which is the path the menu itme points to. 

* Paths
For each menu item you may specify a number of paths, that should match for the item to be active.
Unless you provide the `:path` option for `Mmmenu#add`, the second argument is used as the matching path.
If you'd like to specify paths explicitly, do something like this:

    `l1.add "Articles" articles_path, :paths => [[new_article_path, 'get'], [articles_path, 'post'], [articles_path, 'get']]`

This way, the menu item will appear active even when you're on the /articles/new page.
There's also a third array element, which must be hash. In it may list request_params that should match, for example:

    `l1.add "Articles" articles_path, :paths => [[articles_path, 'get', {:filter => 'published'}]]`

That way, only a request to "/articles?filter=published" will make this menu item active.
Of course it doesn't matter, if the request contains some other params. But you can make sure it doesn't by saying something like `{:personal => nil}` 

Alernatively, you can do this:

    l1.add "Articles" articles_path, :match_subpaths => true

Or you may use wildcards:

    l1.add "Articles" articles_path, :paths => [["/articles/*"]]

That's much easier usually.


INSTALLATION
------------

1. git submodule add git://github.com/snitko/mmmenu.git vendor/plugins/mmmenu
2. script/generate mmmenu
