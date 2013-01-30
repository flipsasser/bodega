module Bodega
  class Cart
    include ActiveModel::Validations

    attr_reader :storage

    def initialize(session_hash)
      @storage = session_hash
    end

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

    private
    def method_missing(method_id, *args, &block)
      if storage.respond_to?(method_id)
        storage.send(method_id, *args, &block)
      else
        super
      end
    end
  end
end
