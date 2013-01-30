module Bodega
  class Order < ActiveRecord::Base
    self.table_name = :bodega_orders
    before_save :set_total
    before_create :set_identifier

    belongs_to :customer, polymorphic: true
    has_many :order_products, class_name: 'Bodega::OrderProduct', dependent: :destroy
    has_many :products, through: :order_products

    monetize :tax_cents
    monetize :total_cents

    def build_products(product_hash)
      self.order_products = product_hash.map do |type, item|
        item = item.symbolize_keys
        OrderProduct.new do |order_product|
          order_product.product_type = item[:type]
          order_product.product_id = item[:id]
          order_product.quantity = item[:quantity]
        end
      end
    end

    def finalize!(options)
      self.class.transaction do
        self.save!
        begin
          self.payment_id = payment_method.complete!(options)
          self.save
        rescue Exception
          raise ActiveRecord::Rollback
        end
      end
    end

    def payment_method
      @payment_method ||= "Bodega::PaymentMethod::#{Bodega.config.payment_method.to_s.camelize}".constantize.new(self)
    end

    def shipping_method
      @shipping_method ||= "Bodega::ShippingMethod::#{Bodega.config.shipping_method.to_s.camelize}".constantize.new(self)
    end

    def subtotal
      @subtotal ||= order_products.inject(Money.new(0)) {|sum, order_product| sum += order_product.subtotal }
    end

    def to_param
      identifier
    end

    protected
    def set_identifier
      self.identifier = self.class.count.succ.to_s(36)
    end
  end
end
