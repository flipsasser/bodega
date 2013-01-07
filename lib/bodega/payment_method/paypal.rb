require 'bodega/payment_method/base'

module Bodega
  module PaymentMethod
    class Paypal < Base
      options :username, :password, :signature

      def checkout_url(success_url, cancel_url)
        response = client.setup(request, success_url, cancel_url)
        response.redirect_uri
      end

      def complete!
        response = client.checkout!(
          options[:token],
          options[:PayerID],
          request
        )
        response.payment_info.last.transaction_id
      end

      protected
      def client
        Paypal.sandbox! if Bodega.test_mode
        @client ||= ::Paypal::Express::Request.new(
          username:  Bodega.config.paypal.username,
          password:  Bodega.config.paypal.password,
          signature: Bodega.config.paypal.signature
        )
      end

      def request
        @request ||= ::Paypal::Payment::Request.new(
          amount: order.subtotal,
          description: order.order_products.map(&:quantity_and_name).to_sentence
        )
      end
    end
  end
end
