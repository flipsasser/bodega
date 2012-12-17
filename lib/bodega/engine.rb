module Bodega
  class Engine < ::Rails::Engine
    isolate_namespace Bodega

    initializer "bodega.hookses" do
      ActiveSupport.on_load :action_controller do
        #require 'bodega/action_controller'
        include Bodega::CartHelper
      end

      ActiveSupport.on_load :active_record do
        require 'bodega/monetize'
      end

      ActiveSupport.on_load :paypal_express do
        raise 'w0tf'
      end
    end
  end
end
