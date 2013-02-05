module Bodega
  class OrderProduct < ActiveRecord::Base
    self.table_name = :bodega_order_products

    attr_accessible :quantity, :product, :product_id, :product_type

    before_save :calculate_total

    belongs_to :order, class_name: 'Bodega::Order'
    belongs_to :product, polymorphic: true

    default_scope order(:created_at)

    delegate :keep_stock?, :price, to: :product

    monetize :total_cents

    validates_numericality_of :quantity, allow_blank: true, minimum: 1
    validates_presence_of :product, :quantity
    validate :product_available?

    def identifier
      "#{product_type}.#{product_id}"
    end

    def name
      product.respond_to?(:name) ? product.name : "#{product_type.titleize} ##{product_id}"
    end

    def update_stock
      if keep_stock?
        product.number_in_stock = product.number_in_stock - quantity
        product.save(validate: false)
      end
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
      return true unless product.keep_stock?
      if !product.in_stock?
        errors.add(:quantity, I18n.t("bodega.sold_out"))
      elsif product.number_in_stock < quantity
        if product.number_in_stock == 1
          errors.add(:quantity, I18n.t("bodega.one_in_stock"))
        else
          errors.add(:quantity, I18n.t("bodega.x_in_stock").gsub(' x ', " #{product.number_in_stock} "))
        end
      end
    end
  end
end
