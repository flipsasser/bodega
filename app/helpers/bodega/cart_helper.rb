module Bodega
  module CartHelper
    def button_to_cart(product, label = 'Add to Cart', options = {}, &block)
      unless options.key? :disabled
        options[:disabled] = !product.in_stock?
      end
      form_contents = hidden_field_tag('order_product[product_type]', product.class)
      form_contents << hidden_field_tag('order_product[product_id]', product.id) +
      if block_given?
        form_contents << capture(&block)
      end
      form_contents << button_tag(label, options)
      form_tag(bodega.add_to_order_path) { form_contents }
    end

    protected
    def current_order
      @current_order ||= Bodega::Order.where(identifier: session[:bodega_order_id]).first || Bodega::Order.new.tap do |order|
        order.customer = send(Bodega.config.customer_method) if Bodega.config.customer_method
      end
    end
  end
end
