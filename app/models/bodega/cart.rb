module Bodega
  class Cart < Hash
    include ActiveModel::Validations

    def quantity(product_id)
      return 0 unless product = self[product_id]
      product[:quantity].to_i
    end

    def update(item)
      product_id = "#{item[:type]}.#{item[:id]}"
      if item[:remove]
        delete product_id
      else
        current_quantity = quantity(product_id)
        new_quantity = item[:quantity] ? item[:quantity].to_i : current_quantity + 1
        self[product_id] = item.merge(quantity: new_quantity)
      end
    end
  end
end
