require 'active_record'
require 'database_cleaner'
require 'logger'
require 'money-rails'

MoneyRails::Hooks.init

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::Severity::UNKNOWN
ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => ':memory:', :pool => 5, :timeout => 5000})

RSpec.configure do |config|
  config.around do |example|
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

  config.before :suite do
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define do
        create_table :test_products, :force => true do |t|
          migrations_path = File.expand_path(File.join("..", "..", "db", "migrate"), File.dirname(__FILE__))
          migrations = Dir[File.join(migrations_path, '*.rb')]
          migrations.each do |migration_file|
            require migration_file
            migration_name = File.basename(migration_file, '.rb')
            migration_name[/^\d+_/] = ''
            migration_name = migration_name.camelize
            puts migration_name.constantize.migrate(:up)
          end
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
end

class TestProduct < ActiveRecord::Base; end
