require File.expand_path(File.dirname(__FILE__) + '/../../lib/mmmenu/level')
require File.expand_path(File.dirname(__FILE__) + '/../../lib/mmmenu')

describe Mmmenu do

  before(:all) do
    @items = [
      { :name => :numbers, :title => 'Item1', :children => [ 
        { :title => 'Create', :href => '/items1/new', :paths => ['/items1/new'] },
        { :title => 'Index', :href => '/items1/'      },
        { :title => 'Print', :href => '/items1/print' }
      ]},
      { :title => 'Item2', :href => '/items2' },
      { :title => 'Item3', :href => '/items3' },
      { :title => 'Item4', :href => '/items4' }
    ]
  end

  before(:each) do
    @request = double('request')
    allow(@request).to receive(:path).and_return('/items1/new')
    allow(@request).to receive(:method).and_return('get')
    allow(@request).to receive(:params).and_return({})
    @menu = Mmmenu.new(:items => @items, :request => @request )
  end

  it "renders one level" do
    set_menu_markup
    @menu.item_markup(2) do |link, text, options|
      "  #{text}: #{link}\n"
    end
    @menu.current_item_markup(2) do |link, text, options|
      "  #{text}: #{link} current\n"
    end
    @menu.level_markup(1) { |menu| menu }
    expect(@menu.build).to eq <<END
Item1:  current
  Create: /items1/new current
  Index: /items1/
  Print: /items1/print
Item2: /items2
Item3: /items3
Item4: /items4
END


  end

  it "chooses the current item depending on request type" do
    items = [
      { :title => 'item1', :href => '/item1', :paths => [['/item', 'post']] },
      { :title => 'item2', :href => '/item2', :paths => [['/item', 'get']] }
    ]
    request = double('request')
    allow(request).to receive(:path).once.and_return('/item')
    allow(request).to receive(:method).once.and_return('get')
    allow(request).to receive(:params).once.and_return({})
    @menu = Mmmenu.new(:items => items, :request => request )
    set_menu_markup
    expect(@menu.build).to eq <<END
item1: /item1
item2: /item2 current
END

  end

  it "chooses the current item with a specific request param" do
    items = [
      { :title => 'item1', :href => '/item1', :paths => [['/item1', 'get',  {:param => 1}]] },
      { :title => 'item2', :href => '/item1', :paths => [['/item1', 'get',  {:param => 2}]] },
      { :title => 'item3', :href => '/item1', :paths => [['/item1', 'get',  {:param => nil}]] }
    ]
    request = double('request')
    allow(request).to receive(:path).once.and_return('/item1')
    allow(request).to receive(:params).once.and_return({"param" => "1"})
    allow(request).to receive(:method).once.and_return('get')
    @menu = Mmmenu.new(:items => items, :request => request )
    set_menu_markup
    expect(@menu.build).to eq <<END
item1: /item1 current
item2: /item1
item3: /item1
END
  end

  it "chooses current item when forced to do so by explicitly set current_item property" do
    items = [
      { :title => 'item1', :href => '/item1' },
      { :title => 'item2', :href => '/item2' },
      { :title => 'item3', :href => '/item3' }
    ]
    request = double('request')
    allow(request).to receive(:path).once.and_return('/item1')
    allow(request).to receive(:method).once.and_return('get')
    allow(request).to receive(:params).once
    @menu = Mmmenu.new(:items => items, :request => request )
    @menu.current_item = "/item2"
    set_menu_markup

    expect(@menu.build).to eq <<END
item1: /item1
item2: /item2 current
item3: /item3
END
  end

  it "creates menu items in a block using nice DSL" do
    
    @menu = Mmmenu.new(:request => @request) do |m|
      m.add 'Item1', '/items1', :match_subpaths => true
      m.add 'Item2', '/items2' do |subm|
        subm.add 'New', '/item2/new'
        subm.add 'Edit', '/item2/edit'
      end
    end
    set_menu_markup

    expect(@menu.build).to eq <<END
Item1: /items1 current
Item2: /items2
New: /item2/new
Edit: /item2/edit
END

  end

  it "creates menu items in a block using nice DSL and additional options" do

    @menu = Mmmenu.new(:request => @request) do |m|
      m.add 'Item1', '/items1', :match_subpaths => true
      m.add 'Item2', '/items2' do |subm|
        subm.add 'New', '/item2/new'
        subm.add 'Edit', '/item2/edit'
      end
    end
    set_menu_markup

    expect(@menu.build).to eq <<END
Item1: /items1 current
Item2: /items2
New: /item2/new
Edit: /item2/edit
END

  end


  it "returns current item title and url" do
    @menu.build
    expect(@menu.current_item).to eq({:title=>"Create", :href=>"/items1/new", :paths=>["/items1/new"], :html_options=>{}})
  end

  def set_menu_markup(level=1)
    @menu.item_markup(level) do |link, text, options|
      "#{text}: #{link}\n"
    end
    @menu.current_item_markup(level) do |link, text, options|
      "#{text}: #{link} current\n"
    end
  end

end
