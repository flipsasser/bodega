class Create<%= product_name.classify.pluralize %> < ActiveRecord::Migration
  def change
    create_table :<%= product_name.tableize %> do
      t.integer :price_in_cents
      t.boolean :for_sale, default: true
      t.boolean :keep_stock, default: false
      t.integer :number_in_stock
      t.datetime :for_sale_at
      t.datetime :not_for_sale_at
    end
  end
end
