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
        Location.new(zip: location_object.postal_code)
      end

      def origin
        @origin ||= location_for(Bodega.config.shipping.origin)
      end

      def packages
        @packages ||= [].tap do |packages|
          order.products.each do |product|
            packages.push(package_for(product)) if shippable?(product)
          end
        end
      end

      def package_for(product)
        Package.new(
          product.weight,
          product.dimensions,
          units: Bodega.config.shipping.units
        )
      end

      def shippable?(product)
        product.respond_to?(:weight) && product.respond_to?(:dimensions)
      end
    end
  end
end
