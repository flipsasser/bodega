module Bodega
  module PaymentMethod
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

      def checkout_url(success_url, cancel_url)
        raise "Implement #{self.class.name}#checkout_url"
      end

      def complete!
        raise "Implement #{self.class.name}#complete!"
      end

      def initialize(order, options)
        self.order = order
        self.options = options
      end
    end
  end
end
