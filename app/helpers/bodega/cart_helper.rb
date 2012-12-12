module Bodega
  module CartHelper
    protected
    def build_order
      order = Bodega::Order.new
      order.order_products = current_products.map do |type, product|
        product = product.symbolize_keys
        OrderProduct.new do |order_product|
          order_product.product_type = product[:type]
          order_product.product_id = product[:id]
          order_product.quantity = product[:quantity]
        end
      end
      order
    end

    def current_order
      @current_order ||= build_order
    end

    def current_products
      session[:bodega_products] ||= {}
    end
  end
end
