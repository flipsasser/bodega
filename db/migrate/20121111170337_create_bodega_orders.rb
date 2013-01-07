require 'money-rails'

class CreateBodegaOrders < ActiveRecord::Migration
  def change
    create_table :bodega_orders do |t|
      t.belongs_to :customer, polymorphic: true
      t.string :identifier, limit: 20
      t.string :payment_id
      t.money :tax
      t.money :total
      t.timestamps
    end
  end
end
