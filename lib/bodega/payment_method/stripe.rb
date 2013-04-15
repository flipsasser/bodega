require 'bodega/payment_method/base'
require 'addressabler'

module Bodega
  module PaymentMethod
    class Stripe < Base
      options :secret_key, :publishable_key

      # Redirect to /cart/complete?stripe=tokenToVerifyPayment
      def checkout_url(success_url, cancel_url, params = {})
        if params[:stripe]
          uri = Addressable::URI.heuristic_parse(success_url)
          uri.query_hash[:stripe] = params[:stripe]
        else
          uri = Addressable::URI.heuristic_parse(cancel_url)
          uri.query_hash[:stripe] = 'yes'
        end
        uri.to_s
      end

      def complete!(options = {})
        ::Stripe.api_key = Bodega.config.stripe.secret_key
        charge = ::Stripe::Charge.create(
          amount: order.total_cents,
          currency: 'usd',
          card: options[:stripe],
          description: order.summary
        )
        charge.id
      end

      def shipping?
        false
      end

      protected
      def client
        ::Paypal.sandbox! if Bodega.config.test_mode
        @client ||= ::Paypal::Express::Request.new(
          username:  Bodega.config.paypal.username,
          password:  Bodega.config.paypal.password,
          signature: Bodega.config.paypal.signature
        )
      end

      def request
        @request ||= ::Paypal::Payment::Request.new(
          amount: order.total.to_f,
          description: order.order_products.map(&:quantity_and_name).to_sentence,
          items: order.order_products.map {|order_product|
            {
              name: order_product.name,
              amount: order_product.price.to_f,
              quantity: order_product.quantity
            }
          },
          shipping_amount: order.shipping.to_f,
          tax_amount: order.tax.to_f
        )
      end
    end
  end
end
