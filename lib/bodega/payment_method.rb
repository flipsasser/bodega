module Bodega
  module PaymentMethod
    autoload :Paypal, 'bodega/payment_method/paypal'
    autoload :Plinq, 'bodega/payment_method/plinq'

    def payment_method
      @payment_method ||= "Bodega::PaymentMethod::#{Bodega.config.payment_method.to_s.classify}".constantize.new(current_order, params)
    end
  end
end
