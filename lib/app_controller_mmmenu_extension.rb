ActionController::Base.class_eval do

  private

    def mmmenu(&block)
      @menu = Mmmenu.new(:request => request, &block)
    end

end
