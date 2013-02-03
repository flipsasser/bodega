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

      def options
        return [] unless packages.any?
        @options ||= [].tap do |options|
          response = client.find_rates(origin, destination, packages)
          response.rates.sort(&:price).each do |rate|
            options.push({
              name: rate.service_name,
              price: Money.new(rate.price)
            })
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
        Location.new(
          city: location_object.city,
          state: location_object.state,
          zip: location_object.postal_code,
          country: location_object.country
        )
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
