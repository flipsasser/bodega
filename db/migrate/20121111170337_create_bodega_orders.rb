class CreateBodegaOrders < ActiveRecord::Migration
  def change
    create_table :bodega_orders do |t|
      t.belongs_to :customer, polymorphic: true
      t.string :identifier, limit: 20
      t.string :payment_id
      t.integer :subtotal_in_cents
      t.integer :tax_in_cents
      t.integer :total_in_cents
      t.timestamps
    end
  end
end
