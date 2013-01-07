module Bodega
  class Engine < ::Rails::Engine
    isolate_namespace Bodega

    initializer "bodega.hookses" do
      ActiveSupport.on_load :action_controller do
        #helper 'bodega/application'
        helper 'bodega/cart'
        include Bodega::CartHelper
      end

      ActiveSupport.on_load :active_record do
      end
    end
  end
end
