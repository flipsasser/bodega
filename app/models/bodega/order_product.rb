module Bodega
  class OrderProduct < ActiveRecord::Base
    extend Bodega::Monetize

    belongs_to :order, class_name: 'Bodega::Order'
    belongs_to :product, polymorphic: true

    delegate :name, :price, to: :product

    monetize :subtotal
    monetize :tax
    monetize :total

    validates_numericality_of :quantity, allow_blank: true, minimum: 1
    validates_presence_of :quantity

    protected
    def calculate_tax
      self.tax = 0
    end

    def calculate_total
      self.subtotal = price * quantity
      self.total = subtotal + calculate_tax
    end
  end
end
