class Bodegaize<%= product_name.classify.pluralize %> < ActiveRecord::Migration
  def change
    add_column :<%= product_name.tableize %>, :price_in_cents, :integer
    add_column :<%= product_name.tableize %>, :for_sale, :boolean, default: true
    add_column :<%= product_name.tableize %>, :keep_stock, :boolean, default: false
    add_column :<%= product_name.tableize %>, :number_in_stock, :integer
    add_column :<%= product_name.tableize %>, :for_sale_at, :datetime
    add_column :<%= product_name.tableize %>, :not_for_sale_at, :datetime
  end
end
