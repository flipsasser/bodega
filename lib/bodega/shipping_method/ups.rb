require 'bodega/shipping_method/base'

module Bodega
  module ShippingMethod
    class UPS < Base
      #options :username, :password, :signature

      protected
      def client
      end

      def request
      end
    end
  end
end
