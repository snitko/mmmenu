require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
    @request = mock('request')
    @request.stub!(:path).once.and_return('/items1/new')
    @request.stub!(:method).once.and_return('get')
    @request.stub!(:params).once.and_return({})
    @menu = Mmmenu.new(:items => @items, :request => @request )
  end

  it "renders one level" do
    @menu.item_markup(0, :active_markup => 'current') do |link, text, options|
      "#{text}: #{link} #{options[:active]}\n"
    end
    @menu.item_markup(2, :active_markup => 'current') do |link, text, options|
      "  #{text}: #{link} #{options[:active]}\n"
    end
    @menu.level_markup(0) { |menu| menu }
    (@menu.build.chomp(" \n") + "\n").should == <<END
Item1:  current
  Create: /items1/new current
  Index: /items1/ 
  Print: /items1/print 
Item2: /items2\s
Item3: /items3\s
Item4: /items4
END

  end

  it "chooses the current item depending on request type" do
    items = [
      { :title => 'item1', :href => '/item1', :paths => [['/item', 'post']] },
      { :title => 'item2', :href => '/item2', :paths => [['/item', 'get']] }
    ]
    request = mock('request')
    request.should_receive(:path).once.and_return('/item')
    request.should_receive(:method).once.and_return('get')
    request.should_receive(:params).once.and_return({})
    @menu = Mmmenu.new(:items => items, :request => request )
    @menu.item_markup(0, :active_markup => 'current') do |link, text, options|
      "#{text}: #{link} #{options[:active]}\n"
    end
    @menu.build.should == <<END
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
    request = mock('request')
    request.should_receive(:path).once.and_return('/item1')
    request.should_receive(:params).once.and_return({"param" => "1"})
    request.should_receive(:method).once.and_return('get')
    @menu = Mmmenu.new(:items => items, :request => request )
    @menu.item_markup(0, :active_markup => 'current') do |link, text, options|
      "#{text}: #{link} #{options[:active]}\n"
    end
    @menu.build.should == <<END
item1: /item1 current
item2: /item1 
item3: /item1 
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

    @menu.build.should == <<END
Item1 /items1 current\s
Item2 /items2\s\s
New /item2/new\s\s
Edit /item2/edit\s\s
END

  end

  it "creates menu items in a block using nice DSL and additional options" do

    @menu = Mmmenu.new(:request => @request) do |m|
      m.add 'Item1', '/items1', :match_subpaths => true
      m.add 'Item2', '/items2', :html => 'whatever' do |subm|
        subm.add 'New', '/item2/new'
        subm.add 'Edit', '/item2/edit', :html => 'huh'
      end
    end

    @menu.build.should == <<END
Item1 /items1 current\s
Item2 /items2  whatever
New /item2/new\s\s
Edit /item2/edit  huh
END

  end

end
