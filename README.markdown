Mmmenu
======

*Flexible menu generator for rails*

Why another menu plugin?
------------------------
All menu plugins I've seen have HTML markup hardcoded into them.
*Mmmenu* offers you a chance to define your own markup, along with
a nice DSL to describe multi-level menu structures.

INSTALLATION
------------

1. gem install mmmenu
2. rails generate mmmenu (optional)

Basic Usage
---------------

Imagine you put this into your controller:

    mmmenu do |l1|

      l1.add "Articles", "/articles" do |l2|
       l2.add "Create article",   new_article_path
       l2.add "Articles authors", "/articles/authors", :match_subpaths => true
      end
      l1.add "Item2", "/path2"
      l1.add "Item3", "/path3"
      l1.add "Item4", "/path4"

    end 

As you can see, we specify the paths, so our menu does not depend on the routes.
`#mmmenu` method automatically puts your menu into @menu instance variable. If you wish to use another variable,
you may use a more explicit syntax:

    @my_menu = Mmmenu.new(:request => request) { |l1| ... }

Now let's see what happens in the views:

  <%= build_mmmenu(@menu) %>

And that's it, you get your menu rendered.

Customizing Views
------------------------
Now, like I promised, the html-markup is totally
configurable.

Run `rails generate mmmenu`, you'll get your app/helpers/mmmenu_helper.rb file and a bunch of templates copied out of the plugin views/mmmenu directory into app/views/mmmenu directory, thus replacing the plugin default files. Here's what those template files are and what they mean:

`_current_item.erb` 	is responsible for the current item in the menu
`_item.erb` 		      is responsible for the non-current items
`level_1.erb`					is a wrapper for menu level 1
`level_2.erb`					is a wrapper for menu level 2 (submenu)

You can also has various templates for various menus on your page. Simply, provide a :templates_path option to #build_mmmenu helper like this:

    <%= build_mmmenu(@menu, templates_path: 'mmmenu/my_custom_menu') %>

Then you can put all the same files mentioned above in this directory and change them. This is useful when you have various types of menus
requiring different html-markup. If you wish to customize deeper levels of menus and items in them, you should take a look at the generated
`mmmenu_helper.rb` file.

Customizing the Helper
----------------------------

Let's take a look at what's inside this helper:

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

You can see now, that `#item_markup` method defines the html markup for menu item,
and `#level_markup` does the same for menu level wrapper. The first argument is the menu level.
You may define as much levels as you want, but you don't need to define markup for each level: the deepest level of the markup
defined will be used for all of the deeper levels.

By default, build_mmmenu helper defines two partial templates for level 1 of the menu.
It does so by calling two methods on a Mmmenu object:
  #current_item_markup defines markup for the current menu item
  #item_markup defines markup for all other menu items
Both methods accept an optional second argument - a hash of html_options:

    menu.item_markup(1, :class => "mmmenu")

which is later used in the templates like this:

    <li><%= link_to text, link, options %></li>

Note, that this is an example from a default template and options hash may not be present in the customized template.

Disclaimer: if you call Mmmenu#item_markup for a certain level, you MUST call Mmmenu#current_item_markup
for the same level.

Most of the time, you will want to customize your views, not the helper, so you may as well delete it from your application/helpers dir.


Finally, let's take a closer look at some of the options and what they mean.
---------------------------------------------------------------------
##### Current item
Mmmenu automatically marks each current menu_item with the markup, that you provide in `#current_item_markup` method's block. The item is considered current not only if the paths
match, but also if one of the children of the item is marked as current. You may as well set the current item manually like that:

    @menu.current_item = '/articles'

In this case `'/articles'` would match against the second argument that you pass to the `#add` method, which is the path the menu itme points to.
Note that unless the item with such path is not present in the menu, then no item will be makred as current. It is a useful technique when you want
to prevent the item from being current in the controller. For example:

    @menu.current_item = '/search-results-pertending-to-be-a-list' if search_query_empty?

##### Paths
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
