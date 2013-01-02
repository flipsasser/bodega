module Bodega
  class Order < ActiveRecord::Base
    extend Bodega::Monetize

    before_create :set_identifier

    belongs_to :customer, polymorphic: true
    has_many :order_products, class_name: 'Bodega::OrderProduct', dependent: :destroy
    has_many :products, through: :order_products

    monetize :subtotal
    monetize :tax
    monetize :total

    def subtotal
      order_products.inject(0) {|sum, order_product| sum += order_product.subtotal }
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
