class Mmmenu

  class Level

    def initialize(&block)
      @items = []
      yield(self)
    end

    def add(title, href, options={}, &block)
      children = {}
      if block_given? # which means current item has children
        children = { :children => self.class.new(&block).to_a }
      end
      @items << { :title => title, :href => href }.merge(options).merge(children)
    end

    def to_a
      @items
    end

  end

end
