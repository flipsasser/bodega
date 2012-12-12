require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module Bodega
  module Generators
    class ProductizeGenerator < Rails::Generators::Base
      argument :product_name, type: :string

      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def copy_migration
        migration_template("migration.rb", "db/migrate/bodegaize_#{product_name.tableize}")
      end
    end
  end
end
