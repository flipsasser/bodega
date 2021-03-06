require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module Bodega
  module Generators
    class ProductGenerator < Rails::Generators::Base
      argument :product_name, type: :string

      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)

      def copy_migration
        migration_template "migration.rb", "db/migrate/create_#{product_name.tableize}"
      end

      def copy_model
        template "model.rb", "app/models/#{product_name.tableize.singularize}"
      end
    end
  end
end
