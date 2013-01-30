module Bodega
  module ShippingMethod
    class Base
      class << self
        def options(*new_options)
          option_namespace = self.name.split('::').pop.underscore
          Bodega.class_eval do
            option option_namespace do
              options(*new_options.flatten)
            end
          end
        end
      end

      attr_accessor :options, :order

      def initialize(order)
        self.order = order
      end
    end
  end
end
