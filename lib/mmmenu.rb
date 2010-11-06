class Mmmenu

  attr_accessor :active_item

  def initialize(options, &block)
    @items          = options[:items] || Mmmenu::Level.new(&block).to_a
    @current_path   = options[:request].path.chomp('/')
    @request_params = options[:request].params
    @request_type   = options[:request].method.to_s.downcase
    @item_markup    = []
    @level_markup   = []
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

      # Parsing of a single menu level happens here
      output          = ''
      has_active_item = false

      raise("Mmmenu object #{self} is empty, no items defined!") if items.nil? or items.empty?
      items.each do |item|

        options = {}
        child_menu = build_level(item[:children], level+1) if item[:children]
        child_output = child_menu[:output] if child_menu
        
        #############################################################
        # Here's where we check if the current item is an active item
        # and we should use a special markup for it
        #############################################################
        if (
          item[:href] == active_item                    or
          item_paths_match?(item)                       or
          (child_menu and child_menu[:has_active_item]) or
          item_href_match?(item)
        ) and !has_active_item
                    
              then
                  options[:active] = item_markup[:active] and has_active_item = true

        end
        #############################################################

        options.merge!(:html => item[:html]) if item[:html]
        item_output = item_markup[:basic].call(item[:href], item[:title], options)
        output += "#{item_output}#{child_output}"
      end

      output = level_markup.call(output)
      { :has_active_item => has_active_item, :output => output }

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
        { :basic => @item_markup[level][:block], :active => @item_markup[level][:active_markup]}
      else
        unless @item_markup.empty?
          { :basic => @item_markup.last[:block], :active => @item_markup.last[:active_markup] }
        else
          { :basic => lambda { |link,text,options| "#{text} #{link} #{options[:active]} #{options[:html]}\n" }, :active => 'current' }
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
