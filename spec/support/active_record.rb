ActiveRecord::Base.logger = Logger.new(File.open('log/test.log', 'w+'))
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:', :pool => 5, :timeout => 5000})

class TestProduct < ActiveRecord::Base; end

RSpec.configure do |config|
  config.around do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

  config.before :suite do
    migrations_path = File.expand_path(File.join("..", "db", "migrate"), File.dirname(__FILE__))
    migrations = Dir[File.join(migrations_path, '*.rb')]
    migrations.each do |migration_file|
      require migration_file
      migration_name = File.basename(migration_file, '.rb')
      migration_name[/^\d+_/] = ''
      migration_name = migration_name.camelize
      puts migration_name.constantize.migrate(:up)
    end
    ActiveRecord::Schema.define do
      create_table :test_products, :force => true do |t|
        t.integer :price_cents
        t.boolean :for_sale, default: true
        t.boolean :keep_stock, default: false
        t.integer :number_in_stock
        t.datetime :for_sale_at
        t.datetime :not_for_sale_at
      end
    end
  end
end
