require 'bodega/engine'
require 'configurator'

module Bodega
  autoload :PaymentMethod, 'bodega/payment_method'

  extend Configurator
  option :customer_method, :current_user
  option :product_name, 'product'
  # Auto-detect payment method. If a user has the Paypal gem installed,
  # it'll use that. If a user has the Plinq gem installed, it'll use that.
  # Otherwise, it'll be all, "HEY I NEED A PAYMENT METHOD" when checkout
  # starts.
  option :payment_method, lambda {
    defined?(::Plinq) ? :plinq : defined?(::Paypal) ? :paypal : raise("No payment method detected. Please set one using `Bodega.config.payment_method=`")
  }
end
