module Bodega
  module Product
    def self.included(base)
      base.class_eval do
        has_many :order_products, as: :product, class_name: 'Bodega::OrderProduct'
        has_many :orders, through: :order_products

        monetize :price_cents

        scope :for_sale, lambda {
          today = Date.today
          where(for_sale: true).
          where(arel_table[:for_sale_at].lteq(today).or(arel_table[:for_sale_at].eq(nil))).
          where(arel_table[:not_for_sale_at].gteq(today).or(arel_table[:not_for_sale_at].eq(nil)))
        }

        scope :popular, joins(%(LEFT JOIN "bodega_order_products" ON "bodega_order_products"."product_id" = "#{table_name}"."id" AND "bodega_order_products"."product_type" = '#{name}')).order('SUM(bodega_order_products.quantity) DESC').group("#{table_name}.id")

        validates_numericality_of :number_in_stock, :if => :keep_stock?
      end
    end

    def in_stock?
      if keep_stock? && number_in_stock
        number_in_stock > 0
      else
        true
      end
    end

    def max_quantity
      keep_stock? ? number_in_stock : Bodega.config.max_quantity
    end
  end
end
