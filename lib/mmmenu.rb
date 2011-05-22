class Mmmenu

  attr_accessor :current_item

  def initialize(options, &block)
    @items          = options[:items] || Mmmenu::Level.new(&block).to_a
    @current_path   = options[:request].path.chomp('/')
    @request_params = options[:request].params
    @request_type   = options[:request].method.to_s.downcase
    @item_markup            = []
    @current_item_markup    = []
    @level_markup           = []
  end

  # The following two methods define
  # the markup for each menu item on the current and
  # lower levels (unless lower levels are not redefined later).
  # Example:
  #   @menu.item_markup(0, options) do |link, text, options|
  #     "<a href=\"#{link}\" #{options}>#{text}</a>"
  #   end
  def item_markup(level, options={}, &block)
    level -= 1
    @item_markup[level] = { :block => block, :options => options }
  end
  def current_item_markup(level, options={}, &block)
    level -= 1
    @current_item_markup[level] = { :block => block, :options => options }
  end

  # Defines the markup wrapper for the current menu level and
  # lower menu levels (unless lower levels are not redefined later).
  # Example:
  #   @menu.level_markup(0) { |level_content| "<div>#{level_content}</div>" }
  def level_markup(level=1, &block)
    level -= 1
    @level_markup[level] = block
  end

  def build
    build_level[:output]
  end

  private

    def build_level(items=@items, level=0)

      item_markup   = build_item_markup(level)
      level_markup  = build_level_markup(level)

      # Parsing of a single menu level happens here
      output          = ''
      has_current_item = false

      raise("Mmmenu object #{self} is empty, no items defined!") if items.nil? or items.empty?
      items.each do |item|

        item[:html_options] = {} unless item[:html_options]
        child_menu = build_level(item[:children], level+1) if item[:children]
        child_output = child_menu[:output] if child_menu
        
        #############################################################
        # Here's where we check if the current item is a current item
        # and we should use a special markup for it
        #############################################################
        if (
          item[:href] == current_item                    or
          item_paths_match?(item)                        or
          (child_menu and child_menu[:has_current_item]) or
          item_href_match?(item)
        ) and !has_current_item
                    
              then
                  has_current_item = true
                  item_output = item_markup[:current][:block].call(item[:href], item[:title], item_markup[:current][:options].merge(item[:html_options]))
        else
          item_output = item_markup[:basic][:block].call(item[:href], item[:title], item_markup[:basic][:options].merge(item[:html_options]))
        end
        #############################################################

        output += "#{item_output}#{child_output}"
      end

      output = level_markup.call(output)
      { :has_current_item => has_current_item, :output => output }

    end


    # Matches menu item against :paths option
    def item_paths_match?(item)
      if item[:paths]

        item[:paths].each do |path|
          if path.kind_of?(Array)
            # IF path matches perfectly
            request_type_option = path[1] || ""
            if ((@current_path == path[0].chomp('/') and @request_type == request_type_option.downcase)  or 
            # OR IF * wildcard is used and path matches
            (path[0] =~ /\*$/ and @current_path =~ /^#{path[0].chomp('*')}(.+)?$/)) and    
            # all listed request params match
            params_match?(path)
              return true 
            end
          else
            return true if @current_path == path
          end
        end

      end
      return false
    end

    # Matches menu item against the actual path it's pointing to.
    # Is only applied when :path option is not present.
    def item_href_match?(item)
      if item[:href]
        item_href = item[:href].chomp('/')
        if (@current_path == item_href) or                                        # IF path matches perfectly
        (item[:match_subpaths] and @current_path =~ /^#{item_href}(\/.+)?$/)      # OR IF :match_subpaths options is used and path matches
          return true
        end
      end unless item[:paths]
      return false
    end

    def build_item_markup(level)
      if @item_markup[level]
        { :basic => @item_markup[level], :current => @current_item_markup[level] }
      else
        unless @item_markup.empty?
          { :basic => @item_markup.last, :current => @current_item_markup.last }
        else
          { :basic => {:block => lambda { |link,text,options| "#{text} #{link} #{options}\n" }, :options => {} }, :current => { :block => lambda { |link,text,options| "#{text} #{link} #{options} current\n" }, :options => {} } }
        end
      end
    end

    def build_level_markup(level)
      if @level_markup[level]
        @level_markup[level]
      else
        if @level_markup.empty?
          lambda { |menu| menu }
        else
          @level_markup.last
        end
      end
    end

    def params_match?(path)
      path[2].each do |k,v|
        return false unless (@request_params[k.to_s].nil? and v.nil?) or @request_params[k.to_s] == v.to_s
      end if path[2]
      true
    end

end
