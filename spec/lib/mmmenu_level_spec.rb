require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Mmmenu::Level do

  it "builds a menu level hash representation" do
    @menu_level = Mmmenu::Level.new do |l1|
      l1.add "Title1", "/path1"
      l1.add "Title2", "/path2" do |l2|
        l2.add "SubTitle", "/path2/subpath"
      end
    end

    @menu_level.to_a.should == [
      {:title => "Title1", :href => "/path1"},
      {:title => "Title2", :href => "/path2", :children => [
        { :title => "SubTitle", :href => "/path2/subpath" }
      ]}
    ]
  end

end
