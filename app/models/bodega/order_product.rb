module Bodega
  class OrderProduct < ActiveRecord::Base
    after_save :update_stock

    belongs_to :order, class_name: 'Bodega::Order'
    belongs_to :product, polymorphic: true

    delegate :keep_stock?, :price, to: :product

    monetize :subtotal_cents
    monetize :tax_cents
    monetize :total_cents

    validates_numericality_of :quantity, allow_blank: true, minimum: 1
    validates_presence_of :quantity
    validate :product_available?

    def decorated_product
      product.respond_to?(:decorator) ? product.decorator.decorate(product) : product
    end

    def finalize!(payment_method)
      self.class.transaction do
        self.save!
        begin
          self.payment_id = payment_method.complete!
          self.save!
        rescue Exception => e
          raise ActiveRecord::Rollback
          raise e.inspect
        end
      end
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

    def product_available?
      unless product.number_in_stock >= quantity
        quantity_error = case quantity
        when 1
          "We're sorry, but the #{name} you requested is no longer in stock."
        else
          "We're sorry, but there are no longer #{quantity} #{name.pluralize} in stock."
        end

        quantity_message = case product.number_in_stock
        when 0
          "They are now sold out."
        when 1
          "There is now one in stock."
        else
          "There are now #{quantity} in stock."
        end

        errors.add(:quantity, "#{quantity_error} #{quantity_message}.")
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
