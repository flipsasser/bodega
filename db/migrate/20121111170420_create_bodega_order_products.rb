class CreateBodegaOrderProducts < ActiveRecord::Migration
  def change
    create_table :bodega_order_products do |t|
      t.belongs_to :order
      t.belongs_to :product, polymorphic: true
      t.integer :quantity
      t.integer :price_in_cents
      t.integer :subtotal_in_cents
      t.integer :tax_in_cents
      t.integer :total_in_cents
    end
  end
end
