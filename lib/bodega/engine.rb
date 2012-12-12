module Bodega
  class Engine < ::Rails::Engine
    isolate_namespace Bodega

    initializer "bodega.action_controller" do
      ActiveSupport.on_load :action_controller do
        require 'bodega/action_controller'
        include Bodega::CartHelper
        include Bodega::ActionController
      end

      ActiveSupport.on_load :active_record do
        require 'bodega/monetize'
      end
    end
  end
end
