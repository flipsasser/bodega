module Bodega
  class Order < ActiveRecord::Base
    extend Bodega::Monetize

    belongs_to :customer, polymorphic: true
    has_many :order_products, class_name: 'Bodega::OrderProduct'
    has_many :products, through: :order_products

    monetize :subtotal
    monetize :tax
    monetize :total

    def subtotal
      order_products.sum(&:subtotal)
    end

    def to_param
      identifier
    end
  end
end
