module Bodega
  module ActionController
    def self.included(base)
      base.helper_method :current_order
    end

    def current_order
      @current_order ||= build_order
    end
    protected :current_order
  end
end
