require 'bodega/shipping_method/base'

module Bodega
  module ShippingMethod
    class UPS < Base
      options :login, :password, :api_key

      protected
      def client
        @client ||= ActiveMerchant::Shipping::UPS.new(
          login: Bodega.config.ups.login,
          password: Bodega.config.ups.password,
          key: Bodega.config.ups.api_key
        )
      end
    end
  end
end
