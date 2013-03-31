require 'bodega/optional'

module Bodega
  module PaymentMethod
    class Base
      extend Bodega::Optional

      attr_accessor :options, :order

      def checkout_url(success_url, cancel_url, params = {})
        raise "Implement #{self.class.name}#checkout_url"
      end

      def complete!(options = {})
        raise "Implement #{self.class.name}#complete!"
      end

      def initialize(order)
        self.order = order
      end
    end
  end
end
