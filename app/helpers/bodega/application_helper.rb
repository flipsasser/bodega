module Bodega
  module ApplicationHelper
    def button_to_cart(product, label = 'Add to Cart')
      form_tag(bodega.add_path) do
        hidden_field_tag('product[type]', product.class) +
        hidden_field_tag('product[id]', product.id) +
        button_tag(label)
      end
    end
  end
end
