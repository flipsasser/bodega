require 'bodega/optional'

module Bodega
  module ShippingMethod
    class Base
      extend Bodega::Optional
      include ActiveMerchant::Shipping if defined?(ActiveMerchant)

      attr_accessor :order

      def initialize(order)
        self.order = order
      end

      def rates
        return {} unless packages.any?
        @rates ||= {}.tap do |rates|
          response = client.find_rates(origin, destination, packages)
          response.rates.sort_by(&:price).each do |rate|
            rates[rate.service_code] = {
              name: rate.service_name,
              price: rate.price
            }
          end
        end
      end

      private
      def client
        raise "Implement #{self.class}#client to return an instance of an ActiveMerchant::Shipping method"
      end

      def destination
        @destination ||= location_for(order)
      end

      def location_for(location_object)
        Location.new(country: Bodega.config.shipping.origin.country, zip: location_object.postal_code)
      end

      def origin
        @origin ||= location_for(Bodega.config.shipping.origin)
      end

      def packages
        @packages ||= [].tap do |packages|
          order.order_products.each do |order_product|
            packages.push(*packages_for(order_product)) if shippable?(order_product.product)
          end
        end
      end

      def packages_for(order_product)
        product = order_product.product
        packages = []
        order_product.quantity.times do
          packages.push(Package.new(product.weight, product.dimensions, units: Bodega.config.shipping.units))
        end
        packages
      end

      def shippable?(product)
        product.respond_to?(:weight) && product.respond_to?(:dimensions)
      end
    end
  end
end
