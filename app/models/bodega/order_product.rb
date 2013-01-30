module Bodega
  class OrderProduct < ActiveRecord::Base
    self.table_name = :bodega_order_products

    after_save :update_stock
    before_save :calculate_total

    belongs_to :order, class_name: 'Bodega::Order'
    belongs_to :product, polymorphic: true

    delegate :keep_stock?, :price, to: :product

    monetize :total_cents

    validates_numericality_of :quantity, allow_blank: true, minimum: 1
    validates_presence_of :quantity
    validate :product_available?

    def identifier
      "#{product_type}.#{product_id}"
    end

    def name
      product.respond_to?(:name) ? product.name : "#{product_type.titleize} ##{product_id}"
    end

    def quantity_and_name
      "#{quantity} x #{name.pluralize(quantity)}"
    end

    def subtotal
      price * quantity
    end

    protected
    def calculate_total
      self.total = subtotal
    end

    def product_available?
      unless product.number_in_stock >= quantity
        quantity_message = case product.number_in_stock
        when 0
          t("sold_out", "Product is sold out.")
        when 1
          t("one_in_stock", "There is now one in stock.")
        else
          t("x_in_stock", "There are now x in stock").gsub(/ x /, quantity)
        end
        errors.add(:quantity, "is too high. #{quantity_message}.")
      end
    end

    def update_stock
      if keep_stock?
        product.number_in_stock = product.number_in_stock - quantity
        product.save(validate: false)
      end
    end
  end
end
