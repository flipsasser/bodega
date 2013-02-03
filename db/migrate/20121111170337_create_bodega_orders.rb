require 'money-rails'

class CreateBodegaOrders < ActiveRecord::Migration
  def change
    create_table :bodega_orders do |t|
      t.belongs_to :customer, polymorphic: true
      t.integer :status
      t.string :identifier, limit: 20
      t.string :payment_id
      t.string :shipping_option, limit: 20
      t.string :tracking_number
      t.string :street_1, limit: 60
      t.string :street_2, limit: 60
      t.string :city, limit: 60
      t.string :state, limit: 3
      t.string :postal_code, limit: 11
      t.string :country, limit: 3
      t.money :shipping
      t.money :tax
      t.money :total
      t.timestamps
    end
  end
end
