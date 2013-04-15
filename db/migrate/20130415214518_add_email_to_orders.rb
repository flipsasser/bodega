class AddEmailToOrders < ActiveRecord::Migration
  def change
    add_column :bodega_orders, :email, :string
  end
end
