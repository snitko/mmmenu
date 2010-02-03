class Mmmenu

  def initialize(options, &block)
    @items        = options[:items] || Mmmenu::Level.new(&block).to_a
    @current_path = options[:request].path.chomp('/')
    @request_type = options[:request].method.to_s
    @item_markup  = []
    @level_markup = []
  end

  # Defines the markup for each menu item on the current and
  # lower levels (unless lower levels are not redefined later).
  # Example:
  #   @menu.item_markup(0, :active_markup => 'class="current"') do |link, text, options|
  #     "<a href=\"#{link}\" #{options}>#{text}</a>"
  #   end
  def item_markup(level, options, &block)
    @item_markup[level] = { :block => block, :active_markup => options[:active_markup] }
  end

  # Defines the markup wrapper for the current menu level and
  # lower menu levels (unless lower levels are not redefined later).
  # Example:
  #   @menu.level_markup(0) { |level_content| "<div>#{level_content}</div>" }
  def level_markup(level=0, &block)
    @level_markup[level] = block
  end

  def build
    build_level[:output]
  end


  private

    def build_level(items=@items, level=0)

      item_markup   = build_item_markup(level)
      level_markup  = build_level_markup(level)

      # Parsing of single menu level happens here
      output          = ''
      has_active_item = false

      raise("Mmmenu object #{self} is empty, no items defined!") if items.nil? or items.empty?
      items.each do |item|

        option_current = nil
        child_menu = build_level(item[:children], level+1) if item[:children]
        child_output = child_menu[:output] if child_menu

        # Current item is active when the paths match
        if item[:paths]

          item[:paths].each do |path|
            if path.kind_of?(Array)
              if (@current_path == path[0].chomp('/') and @request_type == path[1]) or # IF path match perfectly
              (path[0] =~ /\*$/ and @current_path =~ /^#{path[0].chomp('*')}(.+)?$/)   # OR IF * wildcard is used and path matches 
                option_current = item_markup[:active] 
              end
            else
              option_current = item_markup[:active] if @current_path == path
            end
          end
        
        # Current item is active when one of his children is active
        elsif child_menu and child_menu[:has_active_item]
          option_current = item_markup[:active]
        elsif item[:href] and !option_current
          item_href = item[:href].chomp('/')
          if (@current_path == item_href) or                                        # IF path match perfectly
          (item[:match_subpaths] and @current_path =~ /^#{item_href}(\/.+)?$/)      # OR IF :match_subpaths options is used and path matches
            option_current = item_markup[:active]
          end
        else
          option_current = nil
        end
        has_active_item = true if option_current
        
        item_output = item_markup[:basic].call(item[:href], item[:title], option_current)
        output += "#{item_output}#{child_output}"
      end

      output = level_markup.call(output)
      { :has_active_item => has_active_item, :output => output }

    end

    def build_item_markup(level)
      if @item_markup[level]
        { :basic => @item_markup[level][:block], :active => @item_markup[level][:active_markup]}
      else
        unless @item_markup.empty?
          { :basic => @item_markup.last[:block], :active => @item_markup.last[:active_markup] }
        else
          { :basic => lambda { |link,text,options| "#{text} #{link} #{options}\n" }, :active => 'current' }
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

end
