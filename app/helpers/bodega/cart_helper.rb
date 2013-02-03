module Bodega
  module CartHelper
    def button_to_cart(product, label = 'Add to Cart', options = {})
      unless options.key? :disabled
        options[:disabled] = !product.in_stock?
      end
      form_tag(bodega.add_path) do
        hidden_field_tag('product[type]', product.class) +
        hidden_field_tag('product[id]', product.id) +
        button_tag(label, options)
      end
    end

    protected
    def cart
      @cart ||= Bodega::Cart.new(session[:bodega_products] ||= {})
    end

    def current_order
      @current_order ||= Bodega::Order.new.tap do |order|
        order.postal_code = session[:bodega_postal_code]
        order.customer = send(Bodega.config.customer_method) if Bodega.config.customer_method
        order.build_products(cart)
      end
    end
  end
end
