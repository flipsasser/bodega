require 'bodega/engine' if defined?(Rails)
require 'configurator'
require 'i18n'
require 'money-rails'

module Bodega
  autoload :PaymentMethod, 'bodega/payment_method'
  autoload :ShippingMethod, 'bodega/shipping_method'

  extend Configurator
  option :customer_method, :current_user
  option :max_quantity, 1000

  # Auto-detect payment method. If a user has the Paypal gem installed,
  # it'll use that. If a user has the Plinq gem installed, it'll use that.
  # Otherwise, it'll be all, "HEY I NEED A PAYMENT METHOD" when checkout
  # starts.
  option :payment_method, lambda {
    defined?(::Plinq) ? :plinq : defined?(::Paypal) ? :paypal : raise("No payment method detected. Please set one using `Bodega.config.payment_method=`")
  }

  # Defaults to no shipping. Change to :fedex, :ups, or :usps and add
  # `gem "active_shipping"` to gain access to various shipping calculations
  # in the checkout process.
  option :shipping_method, nil
  option :shipping do
    origin do
      city nil
      state nil
      postal_code nil
      country nil
    end
    states []
    units :metric
  end

  # Auto-detect test mode. Defaults to true if running in development or test
  # mode.
  option :test_mode, lambda { Rails.env.development? || Rails.env.test? }
end
