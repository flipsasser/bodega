class CreateBodegaOrderProducts < ActiveRecord::Migration
  def change
    create_table :bodega_order_products do |t|
      t.belongs_to :order
      t.belongs_to :product, polymorphic: true
      t.integer :quantity
      t.money :price
      t.money :subtotal
      t.money :tax
      t.money :total
    end
  end
end
