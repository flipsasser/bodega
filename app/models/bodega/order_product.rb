module Bodega
  class OrderProduct < ActiveRecord::Base
    extend Bodega::Monetize

    after_save :update_stock

    belongs_to :order, class_name: 'Bodega::Order'
    belongs_to :product, polymorphic: true

    delegate :keep_stock?, :price, to: :product

    monetize :subtotal
    monetize :tax
    monetize :total

    validates_numericality_of :quantity, allow_blank: true, minimum: 1
    validates_presence_of :quantity

    def decorated_product
      product.respond_to?(:decorator) ? product.decorator.decorate(product) : product
    end

    def identifier
      "#{product_type}.#{product_id}"
    end

    def name
      decorated_product.respond_to?(:name) ? decorated_product.name : product.to_s
    end

    def quantity_and_name
      "#{quantity} x #{name.pluralize(quantity)}"
    end

    def subtotal
      read_attribute(:subtotal) || price * quantity
    end

    def total
      read_attribute(:total) || subtotal + calculate_tax
    end

    protected
    def calculate_tax
      self.tax = 0
    end

    def calculate_total
      self.subtotal = price * quantity
      self.total = subtotal + calculate_tax
    end

    def update_stock
      if keep_stock?
        product.number_in_stock = product.number_in_stock - quantity
        product.save(validate: false)
      end
    end
  end
end
