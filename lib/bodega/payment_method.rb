module Bodega
  module PaymentMethod
    autoload :Paypal, 'bodega/payment_method/paypal'
    autoload :Plinq, 'bodega/payment_method/plinq'
    autoload :Stripe, 'bodega/payment_method/stripe'
  end
end
