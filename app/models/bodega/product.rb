module Bodega
  module Product
    def self.included(base)
      base.class_eval do
        extend Bodega::Monetize

        has_many :order_products, as: :product, class_name: 'Bodega::OrderProduct'
        has_many :orders, through: :order_products

        monetize :price

        scope :for_sale, lambda {
          where %[
            for_sale IS TRUE OR
            (
              (for_sale_at >= :today OR for_sale_at IS NULL) AND
              (not_for_sale_at <= :today OR not_for_sale_at IS NULL) AND
              (for_sale_at IS NULL AND not_for_sale_at IS NULL) IS NOT TRUE
            )
          ], today: Date.today
        }

        # TODO: Get this to use a regular JOIN
        scope :popular, joins(%(LEFT JOIN "bodega_order_products" ON "bodega_order_products"."product_id" = "#{table_name}"."id" AND "bodega_order_products"."product_type" = '#{name}')).order('SUM(bodega_order_products.quantity) DESC').group("#{table_name}.id")
      end
    end

    def in_stock?
      if keep_stock?
        number_in_stock > 0
      else
        true
      end
    end

    def max_for_sale
      keep_stock? ? number_in_stock : 1000
    end
  end
end
