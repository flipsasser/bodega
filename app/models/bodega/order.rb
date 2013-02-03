require 'maintain'

module Bodega
  class Order < ActiveRecord::Base
    self.table_name = :bodega_orders

    attr_accessor :shipping_options

    attr_accessible :order_products_attributes, :street_1, :street_2, :city, :state, :postal_code

    before_create :set_identifier
    before_save :set_total
    before_save :find_shipping_options, if: :postal_code_changed?

    belongs_to :customer, polymorphic: true

    has_many :order_products, class_name: 'Bodega::OrderProduct', dependent: :destroy
    accepts_nested_attributes_for :order_products

    delegate :empty?, to: :order_products

    maintain :status do
      state :new, 1, default: true
      state :complete, 2

      on :enter, :complete, :mark_order_products_as_purchased
    end

    monetize :shipping_cents
    monetize :tax_cents
    monetize :total_cents

    def finalize!(options)
      self.class.transaction do
        self.status = :complete
        self.save!
        begin
          self.payment_id = payment_method.complete!(options)
          self.save
        rescue Exception
          raise ActiveRecord::Rollback
        end
      end
    end

    def find_shipping_options
      self.shipping_options = shipping_method.options.map do |option|
        "#{option[:name]}: #{option[:price].format}"
      end
    rescue ActiveMerchant::Shipping::ResponseError
    end

    def payment_method
      return nil unless Bodega.config.payment_method
      @payment_method ||= "Bodega::PaymentMethod::#{Bodega.config.payment_method.to_s.camelize}".constantize.new(self)
    end

    def products
      order_products.map(&:product)
    end

    def remove_product(item)
      unless item.is_a?(Bodega::OrderProduct)
        item = order_product(item)
      end
      item.destroy
      order_products.delete(item)
    end

    def shipping_method
      case Bodega.config.shipping_method
      when :ups
        Bodega::ShippingMethod::UPS.new(self)
      end
    end

    def subtotal
      order_products.inject(Money.new(0)) {|sum, order_product| sum += order_product.subtotal }
    end

    def to_param
      identifier
    end

    def update_product(item)
      if order_product = order_product(item)
        if item[:remove]
          remove_product(order_product)
        else
          current_quantity = order_product.quantity
          new_quantity = item[:quantity] ? item[:quantity].to_i : current_quantity + 1
          order_product.update_attributes(quantity: new_quantity)
        end
      else
        order_product = order_products.build({quantity: 1}.merge(item))
      end
      save unless empty?
    end

    protected
    def calculate_shipping
      self.shipping = 0
      if shipping_method && shipping_option
        self.shipping += shipping_method.amount_for(shipping_option)
      end
    end

    def calculate_tax
      self.tax = 0
    end

    def mark_order_products_as_purchased
      order_products.each(&:update_stock)
    end

    def order_product(item)
      if item.is_a?(Hash)
        order_products.detect {|order_product| order_product.product_type == item[:product_type] && order_product.product_id == item[:product_id].to_i }
      else
        order_products.detect {|order_product| order_product.identifier == item }
      end
    end

    def set_identifier
      self.identifier = self.class.count.succ.to_s(36)
    end

    def set_total
      self.total = subtotal + tax #+ shipping
    end
  end
end
